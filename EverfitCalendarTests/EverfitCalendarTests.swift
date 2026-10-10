//
//  EverfitCalendarTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class WorkoutsErrorTests: XCTestCase {

    func testDecodingPreservesUnderlyingError() {
        let underlying = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "bad"))
        let error = WorkoutsError.decoding(underlying)
        XCTAssertNotNil(error.underlying)
        XCTAssertFalse(error.isCancelled)
        XCTAssertTrue(error.localizedDescription.contains("Decoding"))
    }

    func testFromTransportMapsCancellationAndTimeout() {
        XCTAssertTrue(WorkoutsError.fromTransport(URLError(.cancelled)).isCancelled)
        XCTAssertTrue(WorkoutsError.fromTransport(CancellationError()).isCancelled)

        let timeout = WorkoutsError.fromTransport(URLError(.timedOut))
        if case .network(let urlError) = timeout {
            XCTAssertEqual(urlError.code, .timedOut)
        } else {
            XCTFail("Expected network timeout")
        }
    }

    func testHTTPStatusHasNoUnderlyingAndIsUserFacingFailure() {
        let error = WorkoutsError.httpStatus(503)
        XCTAssertNil(error.underlying)
        XCTAssertFalse(error.isCancelled)
    }
}
