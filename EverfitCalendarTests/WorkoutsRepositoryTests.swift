//
//  WorkoutsRepositoryTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class WorkoutsRepositoryTests: XCTestCase {

    private let sample = WorkoutsResponseDTO(data: [
        DayDTO(id: "d0", day: 0, assignments: [
            AssignmentDTO(id: "a0", title: "Legs day", status: 1, totalExercise: 5)
        ])
    ])

    private let updated = WorkoutsResponseDTO(data: [
        DayDTO(id: "d0", day: 0, assignments: [
            AssignmentDTO(id: "a0", title: "Updated legs", status: 1, totalExercise: 5)
        ])
    ])

    func testSuccessfulFetchWritesCache() async throws {
        let cache = InMemoryWorkoutsCache()
        let repository = makeRepository(
            api: .success(sample),
            cache: cache
        )

        let result = await repository.refreshWeek()
        XCTAssertEqual(result.source, .network)
        XCTAssertEqual(result.dto, sample)
        XCTAssertNil(result.error)
        let stored = try await cache.load()
        XCTAssertEqual(stored, sample)
    }

    func testCacheSnapshotReturnsPayloadAndOverrides() async throws {
        let cache = InMemoryWorkoutsCache()
        try await cache.save(sample)
        let completions = InMemoryCompletionStore()
        try await completions.setOverride(id: "a0", isCompleted: true)

        let repository = makeRepository(
            api: .failure(WorkoutsError.httpStatus(500)),
            cache: cache,
            completions: completions
        )

        let snapshot = await repository.loadCachedSnapshot()
        XCTAssertEqual(snapshot.dto, sample)
        XCTAssertEqual(snapshot.overrides["a0"], true)
    }

    func testAPIFailureWithValidCacheReturnsCacheNotFallback() async {
        let cache = InMemoryWorkoutsCache()
        try? await cache.save(sample)
        let fallback = WorkoutsResponseDTO(data: [
            DayDTO(id: "fb", day: 0, assignments: [
                AssignmentDTO(id: "x", title: "Fallback", status: 0, totalExercise: 1)
            ])
        ])

        let repository = makeRepository(
            api: .failure(WorkoutsError.httpStatus(502)),
            fallback: .success(fallback),
            cache: cache
        )

        let result = await repository.refreshWeek()
        XCTAssertEqual(result.source, .cache)
        XCTAssertEqual(result.dto, sample)
        if case .httpStatus(let code) = result.error {
            XCTAssertEqual(code, 502)
        } else {
            XCTFail("Expected original HTTP error")
        }
        let stored = try? await cache.load()
        XCTAssertEqual(stored, sample)
    }

    func testInvalidResponseDoesNotWriteCache() async throws {
        let cache = InMemoryWorkoutsCache()
        try await cache.save(sample)
        let repository = makeRepository(
            api: .failure(WorkoutsError.decoding(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "bad")))),
            cache: cache
        )

        let result = await repository.refreshWeek()
        XCTAssertEqual(result.source, .cache)
        let storedAfterFailure = try await cache.load()
        XCTAssertEqual(storedAfterFailure, sample)
        XCTAssertNotNil(result.error)
    }

    func testWriteFailureStillReturnsNetworkDTO() async {
        let cache = InMemoryWorkoutsCache()
        await cache.setSaveError(WorkoutsError.cacheWriteFailed(MissingResourceError(name: "disk")))
        let repository = makeRepository(api: .success(updated), cache: cache)

        let result = await repository.refreshWeek()
        XCTAssertEqual(result.dto, updated)
        XCTAssertEqual(result.source, .network)
        if case .cacheWriteFailed = result.error {
            return
        }
        XCTFail("Expected cacheWriteFailed, got \(String(describing: result.error))")
    }

    func testCorruptCacheIsIgnoredThenNetworkWritesNewFile() async throws {
        let cache = InMemoryWorkoutsCache()
        await cache.setLoadError(WorkoutsError.cacheCorrupted(MissingResourceError(name: "bad")))
        let repository = makeRepository(api: .success(sample), cache: cache)

        let snapshot = await repository.loadCachedSnapshot()
        XCTAssertNil(snapshot.dto)

        await cache.setLoadError(nil)
        let result = await repository.refreshWeek()
        XCTAssertEqual(result.source, .network)
        let storedAfterRefresh = try await cache.load()
        XCTAssertEqual(storedAfterRefresh, sample)
    }

    func testAPIAndFallbackFailureWithNoCacheYieldsNoDataAvailable() async {
        let repository = makeRepository(
            api: .failure(WorkoutsError.network(URLError(.notConnectedToInternet))),
            fallback: .failure(WorkoutsError.fallbackUnavailable(MissingResourceError(name: "x")))
        )

        let result = await repository.refreshWeek()
        XCTAssertEqual(result.source, .none)
        XCTAssertNil(result.dto)
        if case .noDataAvailable = result.error {
            return
        }
        XCTFail("Expected noDataAvailable, got \(String(describing: result.error))")
    }

    func testCancellationDoesNotUseFallbackOrCache() async throws {
        let cache = InMemoryWorkoutsCache()
        try await cache.save(sample)
        let repository = makeRepository(
            api: .failure(WorkoutsError.cancelled),
            fallback: .success(sample),
            cache: cache
        )

        let result = await repository.refreshWeek()
        XCTAssertTrue(result.error?.isCancelled == true)
        XCTAssertNil(result.dto)
        XCTAssertEqual(result.source, .none)
    }

    func testFallbackIsNotPersistedAsServerCache() async throws {
        let cache = InMemoryWorkoutsCache()
        let fallback = WorkoutsResponseDTO(data: [
            DayDTO(id: "fb", day: 0, assignments: [
                AssignmentDTO(id: "x", title: "Fallback", status: 0, totalExercise: 1)
            ])
        ])
        let repository = makeRepository(
            api: .failure(WorkoutsError.network(URLError(.timedOut))),
            fallback: .success(fallback),
            cache: cache
        )

        let result = await repository.refreshWeek()
        XCTAssertEqual(result.source, .fallback)
        XCTAssertEqual(result.dto, fallback)
        let storedFallback = try await cache.load()
        XCTAssertNil(storedFallback)
        let saves = await cache.saveCount
        XCTAssertEqual(saves, 0)
    }

    private func makeRepository(
        api: Result<WorkoutsResponseDTO, Error>,
        fallback: Result<WorkoutsResponseDTO, Error> = .failure(
            WorkoutsError.fallbackUnavailable(MissingResourceError(name: "x"))
        ),
        cache: InMemoryWorkoutsCache = InMemoryWorkoutsCache(),
        completions: InMemoryCompletionStore = InMemoryCompletionStore()
    ) -> WorkoutsRepository {
        WorkoutsRepository(
            api: StubAPI(result: api),
            fallback: StubFallback(result: fallback),
            cache: cache,
            completions: completions
        )
    }
}

private extension InMemoryWorkoutsCache {
    func setLoadError(_ error: Error?) {
        loadError = error
    }

    func setSaveError(_ error: Error?) {
        saveError = error
    }
}
