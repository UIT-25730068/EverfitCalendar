//
//  WorkoutMappingTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class WorkoutMappingTests: XCTestCase {

    private var calendar: Calendar!
    private var weekDays: [CalendarDay]!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let today = calendar.date(from: DateComponents(year: 2026, month: 10, day: 7))!
        weekDays = CalendarWeekFactory().makeCurrentWeek(for: today, calendar: calendar)
    }

    func testMapsAssignmentsOntoMatchingDayIndexes() {
        let dto = WorkoutsResponseDTO(data: [
            DayDTO(id: "d0", day: 0, assignments: [
                AssignmentDTO(id: "a0", title: "Legs day", status: 1, totalExercise: 5)
            ]),
            DayDTO(id: "d4", day: 4, assignments: [
                AssignmentDTO(id: "a4a", title: "Legs day", status: 0, totalExercise: 7),
                AssignmentDTO(id: "a4b", title: "HIIT Tabata 20:10 8x8", status: 0, totalExercise: 15)
            ]),
            DayDTO(id: "invalid", day: 9, assignments: [
                AssignmentDTO(id: "ignored", title: "Nope", status: 0, totalExercise: 1)
            ])
        ])

        let mapped = WorkoutMapping.map(
            dto: dto,
            weekDays: weekDays,
            today: weekDays[2].date,
            calendar: calendar
        )

        XCTAssertEqual(mapped.count, 7)
        XCTAssertEqual(mapped[0].workouts.map(\.title), ["Legs day"])
        XCTAssertEqual(mapped[4].workouts.map(\.exerciseCount), [7, 15])
        XCTAssertTrue(mapped[2].workouts.isEmpty)
        XCTAssertFalse(mapped.contains { $0.workouts.contains { $0.id == "ignored" } })
    }

    func testOverrideWinsOverAPISeed() {
        let dto = WorkoutsResponseDTO(data: [
            DayDTO(id: "d1", day: 1, assignments: [
                AssignmentDTO(id: "warm", title: "Full warm up workout", status: 2, totalExercise: 6)
            ])
        ])

        let withoutOverride = WorkoutMapping.map(
            dto: dto,
            weekDays: weekDays,
            today: weekDays[2].date,
            calendar: calendar
        )
        XCTAssertEqual(withoutOverride[1].workouts.first?.isCompleted, true)

        let withOverride = WorkoutMapping.map(
            dto: dto,
            weekDays: weekDays,
            today: weekDays[2].date,
            calendar: calendar,
            overrides: ["warm": false]
        )
        XCTAssertEqual(withOverride[1].workouts.first?.isCompleted, false)
        XCTAssertEqual(withOverride[1].workouts.first?.displayStatus, .missed)
    }

    func testUnknownStatusDoesNotCrashAndIsNotTreatedAsCompleted() {
        let dto = WorkoutsResponseDTO(data: [
            DayDTO(id: "d0", day: 0, assignments: [
                AssignmentDTO(id: "x", title: "Unknown", status: 99, totalExercise: 1)
            ])
        ])

        let mapped = WorkoutMapping.map(
            dto: dto,
            weekDays: weekDays,
            today: weekDays[2].date,
            calendar: calendar
        )
        XCTAssertEqual(mapped[0].workouts.first?.isCompleted, false)
    }
}
