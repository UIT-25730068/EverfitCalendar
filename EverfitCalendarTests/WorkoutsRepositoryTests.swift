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

    func testSuccessfulFetchReturnsNetworkSource() async {
        let repository = WorkoutsRepository(
            api: StubAPI(result: .success(sample)),
            fallback: StubFallback(result: .failure(WorkoutsError.fallbackUnavailable(MissingResourceError(name: "x"))))
        )

        let result = await repository.refreshWeek()
        XCTAssertEqual(result.source, .network)
        XCTAssertEqual(result.dto, sample)
        XCTAssertNil(result.error)
    }

    func testAPIFailureUsesFallbackAndPreservesAPIError() async {
        let repository = WorkoutsRepository(
            api: StubAPI(result: .failure(WorkoutsError.httpStatus(502))),
            fallback: StubFallback(result: .success(sample))
        )

        let result = await repository.refreshWeek()
        XCTAssertEqual(result.source, .fallback)
        XCTAssertEqual(result.dto, sample)
        if case .httpStatus(let code) = result.error {
            XCTAssertEqual(code, 502)
        } else {
            XCTFail("Expected original HTTP error")
        }
    }

    func testAPIAndFallbackFailureYieldsNoDataAvailable() async {
        let repository = WorkoutsRepository(
            api: StubAPI(result: .failure(WorkoutsError.network(URLError(.notConnectedToInternet)))),
            fallback: StubFallback(result: .failure(WorkoutsError.fallbackUnavailable(MissingResourceError(name: "x"))))
        )

        let result = await repository.refreshWeek()
        XCTAssertEqual(result.source, .none)
        XCTAssertNil(result.dto)
        if case .noDataAvailable = result.error {
            return
        }
        XCTFail("Expected noDataAvailable, got \(String(describing: result.error))")
    }

    func testCancellationDoesNotUseFallback() async {
        let repository = WorkoutsRepository(
            api: StubAPI(result: .failure(WorkoutsError.cancelled)),
            fallback: StubFallback(result: .success(sample))
        )

        let result = await repository.refreshWeek()
        XCTAssertTrue(result.error?.isCancelled == true)
        XCTAssertNil(result.dto)
        XCTAssertEqual(result.source, .none)
    }
}

private struct StubAPI: WorkoutsFetching {
    let result: Result<WorkoutsResponseDTO, Error>

    func fetchWorkouts() async throws -> WorkoutsResponseDTO {
        try result.get()
    }
}

private struct StubFallback: WorkoutsFallbackLoading {
    let result: Result<WorkoutsResponseDTO, Error>

    func loadFallback() throws -> WorkoutsResponseDTO {
        try result.get()
    }
}
