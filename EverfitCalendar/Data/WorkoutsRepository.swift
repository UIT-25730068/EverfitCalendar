//
//  WorkoutsRepository.swift
//  EverfitCalendar
//

import Foundation
import os

enum WorkoutDataSource: Equatable {
    case network
    case fallback
    case none
}

struct WeekLoadResult {
    let dto: WorkoutsResponseDTO?
    let source: WorkoutDataSource
    let error: WorkoutsError?
}

/// Network + bundled fallback only. Disk cache and completion overrides come in later steps.
final class WorkoutsRepository {

    private let api: WorkoutsFetching
    private let fallback: WorkoutsFallbackLoading
    private let logger = Logger(subsystem: "com.ThanhND.EverfitCalendar", category: "Repository")

    init(
        api: WorkoutsFetching = WorkoutsAPIClient(),
        fallback: WorkoutsFallbackLoading = BundledWorkoutsFallback()
    ) {
        self.api = api
        self.fallback = fallback
    }

    func refreshWeek() async -> WeekLoadResult {
        do {
            try Task.checkCancellation()
            let dto = try await api.fetchWorkouts()
            return WeekLoadResult(dto: dto, source: .network, error: nil)
        } catch {
            let apiError = WorkoutsError.fromTransport(error)
            if apiError.isCancelled {
                return WeekLoadResult(dto: nil, source: .none, error: .cancelled)
            }

            logger.error("API failed: \(apiError.localizedDescription, privacy: .public)")

            do {
                try Task.checkCancellation()
                let fallbackDTO = try fallback.loadFallback()
                logger.error("Using bundled fallback after API failure")
                return WeekLoadResult(dto: fallbackDTO, source: .fallback, error: apiError)
            } catch let fallbackError {
                if fallbackError is CancellationError {
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
}
