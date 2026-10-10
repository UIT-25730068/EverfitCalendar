//
//  WorkoutStatusResolverTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class WorkoutStatusResolverTests: XCTestCase {

    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    }

    func testPastIncompleteIsMissed() {
        XCTAssertEqual(resolve(dayOffset: -1, isCompleted: false), .missed)
    }

    func testPastCompleteIsCompleted() {
        XCTAssertEqual(resolve(dayOffset: -1, isCompleted: true), .completed)
    }

    func testTodayIncompleteIsAssigned() {
        XCTAssertEqual(resolve(dayOffset: 0, isCompleted: false), .assigned)
    }

    func testTodayCompleteIsCompleted() {
        XCTAssertEqual(resolve(dayOffset: 0, isCompleted: true), .completed)
    }

    func testFutureIsAlwaysFuture() {
        XCTAssertEqual(resolve(dayOffset: 1, isCompleted: false), .future)
        XCTAssertEqual(resolve(dayOffset: 1, isCompleted: true), .future)
    }

    private func resolve(dayOffset: Int, isCompleted: Bool) -> WorkoutDisplayStatus {
        let today = calendar.date(from: DateComponents(year: 2026, month: 10, day: 10))!
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return WorkoutStatusResolver.resolve(
            date: date,
            today: today,
            isCompleted: isCompleted,
            calendar: calendar
        )
    }
}
