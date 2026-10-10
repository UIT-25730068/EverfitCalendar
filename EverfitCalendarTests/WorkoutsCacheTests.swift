//
//  WorkoutsCacheTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class WorkoutsCacheTests: XCTestCase {

    private var directory: URL!

    override func setUp() {
        super.setUp()
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    func testMissingCacheFileReturnsNil() async throws {
        let cache = WorkoutsCache(directory: directory)
        let loaded = try await cache.load()
        XCTAssertNil(loaded)
    }

    func testRoundTripPayload() async throws {
        let cache = WorkoutsCache(directory: directory)
        let dto = WorkoutsResponseDTO(data: [
            DayDTO(id: "d0", day: 0, assignments: [
                AssignmentDTO(id: "a0", title: "Legs day", status: 1, totalExercise: 5)
            ])
        ])
        try await cache.save(dto)
        let loaded = try await cache.load()
        XCTAssertEqual(loaded, dto)
    }

    func testCorruptFileThrowsCacheCorrupted() async {
        let url = directory.appendingPathComponent(WorkoutsCache.fileName)
        try? Data("not-json".utf8).write(to: url)
        let cache = WorkoutsCache(directory: directory)

        do {
            _ = try await cache.load()
            XCTFail("Expected corruption error")
        } catch let error as WorkoutsError {
            if case .cacheCorrupted = error {
                XCTAssertNotNil(error.underlying)
            } else {
                XCTFail("Expected cacheCorrupted, got \(error)")
            }
        } catch {
            XCTFail("Unexpected \(error)")
        }
    }

    func testOverrideRoundTrip() async throws {
        let store = CompletionStore(directory: directory)
        let empty = try await store.load()
        XCTAssertEqual(empty, [:])

        try await store.setOverride(id: "a0", isCompleted: true)
        let reloaded = CompletionStore(directory: directory)
        let loaded = try await reloaded.load()
        XCTAssertEqual(loaded["a0"], true)
    }
}
