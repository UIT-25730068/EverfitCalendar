//
//  WorkoutsRepository.swift
//  EverfitCalendar
//

import Foundation
import os

enum WorkoutDataSource: Equatable {
    case cache
    case network
    case fallback
    case none
}

struct CachedSnapshot {
    var dto: WorkoutsResponseDTO?
    var overrides: [String: Bool]
    var error: WorkoutsError?
}

struct WeekLoadResult {
    let dto: WorkoutsResponseDTO?
    let source: WorkoutDataSource
    let error: WorkoutsError?
}

final class WorkoutsRepository {

    private let api: WorkoutsFetching
    private let fallback: WorkoutsFallbackLoading
    private let cache: WorkoutsCaching
    private let completions: CompletionStoring
    private let logger = Logger(subsystem: "com.ThanhND.EverfitCalendar", category: "Repository")

    init(
        api: WorkoutsFetching = WorkoutsAPIClient(),
        fallback: WorkoutsFallbackLoading = BundledWorkoutsFallback(),
        cache: WorkoutsCaching = WorkoutsCache(),
        completions: CompletionStoring = CompletionStore()
    ) {
        self.api = api
        self.fallback = fallback
        self.cache = cache
        self.completions = completions
    }

    func loadCachedSnapshot() async -> CachedSnapshot {
        if Task.isCancelled {
            return CachedSnapshot(dto: nil, overrides: [:], error: .cancelled)
        }

        let overrides = await loadOverridesSafely()
        let payload = await loadCacheSafely()
        return CachedSnapshot(
            dto: payload.dto,
            overrides: overrides.value,
            error: payload.error ?? overrides.error
        )
    }

    func refreshWeek() async -> WeekLoadResult {
        do {
            try Task.checkCancellation()
            let dto = try await api.fetchWorkouts()
            try Task.checkCancellation()
            do {
                try await cache.save(dto)
                return WeekLoadResult(dto: dto, source: .network, error: nil)
            } catch {
                let writeError = WorkoutsError.fromTransport(error)
                if writeError.isCancelled {
                    return WeekLoadResult(dto: nil, source: .none, error: .cancelled)
                }
                logger.error("Cache write failed: \(writeError.localizedDescription, privacy: .public)")
                return WeekLoadResult(dto: dto, source: .network, error: writeError)
            }
        } catch {
            let apiError = WorkoutsError.fromTransport(error)
            if apiError.isCancelled {
                return WeekLoadResult(dto: nil, source: .none, error: .cancelled)
            }

            logger.error("API failed: \(apiError.localizedDescription, privacy: .public)")

            if Task.isCancelled {
                return WeekLoadResult(dto: nil, source: .none, error: .cancelled)
            }

            let cached = await loadCacheSafely()
            if let dto = cached.dto {
                return WeekLoadResult(dto: dto, source: .cache, error: apiError)
            }

            do {
                try Task.checkCancellation()
                let fallbackDTO = try fallback.loadFallback()
                logger.error("Using bundled fallback after API failure; not persisting as server cache")
                return WeekLoadResult(dto: fallbackDTO, source: .fallback, error: apiError)
            } catch let fallbackError {
                if fallbackError is CancellationError || Task.isCancelled {
                    return WeekLoadResult(dto: nil, source: .none, error: .cancelled)
                }
                let mappedFallback = WorkoutsError.fromTransport(fallbackError)
                if mappedFallback.isCancelled {
                    return WeekLoadResult(dto: nil, source: .none, error: .cancelled)
                }
                logger.error("Fallback failed: \(mappedFallback.localizedDescription, privacy: .public)")
                return WeekLoadResult(
                    dto: nil,
                    source: .none,
                    error: .noDataAvailable(apiError)
                )
            }
        }
    }

    func setOverride(id: String, isCompleted: Bool) async {
        do {
            try Task.checkCancellation()
            try await completions.setOverride(id: id, isCompleted: isCompleted)
        } catch {
            let mapped = WorkoutsError.fromTransport(error)
            if mapped.isCancelled { return }
            logger.error("Override write failed: \(mapped.localizedDescription, privacy: .public)")
        }
    }

    private func loadCacheSafely() async -> (dto: WorkoutsResponseDTO?, error: WorkoutsError?) {
        do {
            try Task.checkCancellation()
            let dto = try await cache.load()
            return (dto, nil)
        } catch {
            let mapped = WorkoutsError.fromTransport(error)
            if mapped.isCancelled {
                return (nil, .cancelled)
            }
            logger.error("Cache read failed: \(mapped.localizedDescription, privacy: .public)")
            return (nil, mapped)
        }
    }

    private func loadOverridesSafely() async -> (value: [String: Bool], error: WorkoutsError?) {
        do {
            try Task.checkCancellation()
            let value = try await completions.load()
            return (value, nil)
        } catch {
            let mapped = WorkoutsError.fromTransport(error)
            if mapped.isCancelled {
                return ([:], .cancelled)
            }
            logger.error("Override read failed: \(mapped.localizedDescription, privacy: .public)")
            return ([:], mapped)
        }
    }
}
