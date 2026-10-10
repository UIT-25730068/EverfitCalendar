//
//  CalendarWeekFactoryTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class CalendarWeekFactoryTests: XCTestCase {

    private let factory = CalendarWeekFactory()

    func testWeekStartsMondayEvenWhenCalendarPrefersSunday() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 1

        let wednesday = date(2026, 10, 7, calendar: calendar)
        let days = factory.makeCurrentWeek(for: wednesday, calendar: calendar)

        XCTAssertEqual(days.count, 7)
        XCTAssertEqual(days.map(\.weekdayShort), ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
        XCTAssertEqual(days.map(\.dayNumber), ["5", "6", "7", "8", "9", "10", "11"])
        XCTAssertEqual(days[2].isToday, true)
    }

    func testSundayBelongsToWeekThatStartedPreviousMonday() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 1

        let sunday = date(2026, 10, 11, calendar: calendar)
        let monday = date(2026, 10, 12, calendar: calendar)

        let sundayWeek = factory.makeCurrentWeek(for: sunday, calendar: calendar)
        let mondayWeek = factory.makeCurrentWeek(for: monday, calendar: calendar)

        XCTAssertEqual(sundayWeek.first?.dayNumber, "5")
        XCTAssertEqual(mondayWeek.first?.dayNumber, "12")
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
