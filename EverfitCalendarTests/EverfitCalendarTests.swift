//
//  EverfitCalendarTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class EverfitCalendarTests: XCTestCase {

    func testWorkoutsErrorPreservesUnderlyingDecodingError() {
        let underlying = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "bad"))
        let error = WorkoutsError.decoding(underlying)
        XCTAssertNotNil(error.underlying)
        XCTAssertFalse(error.isCancelled)
    }

    func testFromTransportMapsURLErrorCancelled() {
        XCTAssertTrue(WorkoutsError.fromTransport(URLError(.cancelled)).isCancelled)
        XCTAssertTrue(WorkoutsError.fromTransport(CancellationError()).isCancelled)
    }
}
