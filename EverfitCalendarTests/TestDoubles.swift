//
//  TestDoubles.swift
//  EverfitCalendarTests
//

import Foundation
@testable import EverfitCalendar

struct StubAPI: WorkoutsFetching {
    var result: Result<WorkoutsResponseDTO, Error>

    func fetchWorkouts() async throws -> WorkoutsResponseDTO {
        try result.get()
    }
}

/// Parks `fetchWorkouts` until `resume` is called so tests stay deterministic without sleeps.
final class GatedAPI: WorkoutsFetching, @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<WorkoutsResponseDTO, Error>?
    private var pending: Result<WorkoutsResponseDTO, Error>?

    var isWaiting: Bool {
        lock.lock()
        defer { lock.unlock() }
        return continuation != nil
    }

    func fetchWorkouts() async throws -> WorkoutsResponseDTO {
        try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            if let pending {
                self.pending = nil
                lock.unlock()
                continuation.resume(with: pending)
            } else {
                self.continuation = continuation
                lock.unlock()
            }
        }
    }

    func resume(_ result: Result<WorkoutsResponseDTO, Error>) {
        lock.lock()
        if let continuation {
            self.continuation = nil
            lock.unlock()
            continuation.resume(with: result)
        } else {
            pending = result
            lock.unlock()
        }
    }
}

struct StubFallback: WorkoutsFallbackLoading {
    var result: Result<WorkoutsResponseDTO, Error>

    func loadFallback() throws -> WorkoutsResponseDTO {
        try result.get()
    }
}

actor InMemoryWorkoutsCache: WorkoutsCaching {
    var dto: WorkoutsResponseDTO?
    var loadError: Error?
    var saveError: Error?
    private(set) var saveCount = 0

    func load() async throws -> WorkoutsResponseDTO? {
        if let loadError { throw loadError }
        return dto
    }

    func save(_ dto: WorkoutsResponseDTO) async throws {
        saveCount += 1
        if let saveError { throw saveError }
        self.dto = dto
    }
}

actor InMemoryCompletionStore: CompletionStoring {
    var overrides: [String: Bool] = [:]
    var loadError: Error?
    var saveError: Error?

    func load() async throws -> [String: Bool] {
        if let loadError { throw loadError }
        return overrides
    }

    func setOverride(id: String, isCompleted: Bool) async throws {
        if let saveError { throw saveError }
        overrides[id] = isCompleted
    }
}

func waitUntil(_ condition: () async -> Bool, attempts: Int = 1_000) async -> Bool {
    for _ in 0..<attempts {
        if await condition() { return true }
        await Task.yield()
    }
    return false
}
