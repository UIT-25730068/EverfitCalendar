//
//  WorkoutStatusResolverTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class WorkoutStatusResolverTests: XCTestCase {

    private var calendar: Calendar!
    private var today: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        today = calendar.date(from: DateComponents(year: 2026, month: 10, day: 10, hour: 15))!
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

    func testFutureIsAlwaysFutureRegardlessOfCompletion() {
        XCTAssertEqual(resolve(dayOffset: 1, isCompleted: false), .future)
        XCTAssertEqual(resolve(dayOffset: 1, isCompleted: true), .future)
        XCTAssertFalse(WorkoutDisplayStatus.future.isTappable)
    }

    func testSameCalendarDayDifferentTimesIsToday() {
        let morning = calendar.date(from: DateComponents(year: 2026, month: 10, day: 10, hour: 1))!
        let eveningToday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 10, hour: 23, minute: 50))!
        let resolver = WorkoutStatusResolver(today: eveningToday, calendar: calendar)
        XCTAssertEqual(resolver.resolve(date: morning, isCompleted: false), .assigned)
    }

    func testInjectedReferenceDateChangesResolution() {
        let monday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 5))!
        let friday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 9))!

        let asMonday = WorkoutStatusResolver(today: monday, calendar: calendar)
        let asFriday = WorkoutStatusResolver(today: friday, calendar: calendar)

        XCTAssertEqual(asMonday.resolve(date: friday, isCompleted: false), .future)
        XCTAssertEqual(asFriday.resolve(date: friday, isCompleted: false), .assigned)
        XCTAssertEqual(asFriday.resolve(date: monday, isCompleted: false), .missed)
    }
}

private extension WorkoutStatusResolverTests {
    func resolve(dayOffset: Int, isCompleted: Bool) -> WorkoutDisplayStatus {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return WorkoutStatusResolver(today: today, calendar: calendar)
            .resolve(date: date, isCompleted: isCompleted)
    }
}
