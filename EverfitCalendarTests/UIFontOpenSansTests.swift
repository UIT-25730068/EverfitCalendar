//
//  UIFontOpenSansTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class UIFontOpenSansTests: XCTestCase {

    func testOpenSansFacesNeverReturnNilAndKeepRequestedSize() {
        XCTAssertEqual(UIFont.openSansRegular(ofSize: 16).pointSize, 16, accuracy: 0.01)
        XCTAssertEqual(UIFont.openSansMedium(ofSize: 16).pointSize, 16, accuracy: 0.01)
        XCTAssertEqual(UIFont.openSansBold(ofSize: 22).pointSize, 22, accuracy: 0.01)
    }

    func testCalendarStyleUsesOpenSansRegularSizes() {
        XCTAssertEqual(CalendarStyle.titleFont.pointSize, 15, accuracy: 0.01)
        XCTAssertEqual(CalendarStyle.weekdayFont.pointSize, 11, accuracy: 0.01)
        XCTAssertEqual(CalendarStyle.dateFont.pointSize, 22, accuracy: 0.01)
        XCTAssertEqual(CalendarStyle.cardTitleFont.pointSize, 16, accuracy: 0.01)
        XCTAssertEqual(CalendarStyle.cardMetaFont.pointSize, 13, accuracy: 0.01)
        XCTAssertEqual(CalendarStyle.errorFont.pointSize, 14, accuracy: 0.01)
        XCTAssertEqual(CalendarStyle.retryFont.pointSize, 14, accuracy: 0.01)
    }
}
