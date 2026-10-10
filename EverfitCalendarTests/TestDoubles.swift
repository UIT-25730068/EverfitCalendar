//
//  TestDoubles.swift
//  EverfitCalendarTests
//

import Foundation
@testable import EverfitCalendar

struct StubAPI: WorkoutsFetching {
    var result: Result<WorkoutsResponseDTO, Error>
    var delayNanoseconds: UInt64 = 0

    func fetchWorkouts() async throws -> WorkoutsResponseDTO {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return try result.get()
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
