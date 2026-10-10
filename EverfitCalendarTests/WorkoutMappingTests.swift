//
//  WorkoutMappingTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

final class WorkoutMappingTests: XCTestCase {

    private var calendar: Calendar!
    private var weekDays: [CalendarDay]!
    private var resolver: WorkoutStatusResolver!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let today = calendar.date(from: DateComponents(year: 2026, month: 10, day: 7))!
        weekDays = CalendarWeekFactory().makeCurrentWeek(for: today, calendar: calendar)
        resolver = WorkoutStatusResolver(today: today, calendar: calendar)
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

        let mapped = WorkoutMapping.map(dto: dto, weekDays: weekDays, resolver: resolver)

        XCTAssertEqual(mapped.count, 7)
        XCTAssertEqual(mapped[0].workouts.map(\.title), ["Legs day"])
        XCTAssertEqual(mapped[4].workouts.map(\.exerciseCount), [7, 15])
        XCTAssertTrue(mapped[2].workouts.isEmpty)
        XCTAssertFalse(mapped.contains { $0.workouts.contains { $0.id == "ignored" } })
    }

    func testMissingDTODaysKeepEmptyHeaders() {
        let dto = WorkoutsResponseDTO(data: [])
        let mapped = WorkoutMapping.map(dto: dto, weekDays: weekDays, resolver: resolver)
        XCTAssertEqual(mapped.count, 7)
        XCTAssertTrue(mapped.allSatisfy(\.workouts.isEmpty))
        XCTAssertEqual(mapped.map(\.dayNumber), weekDays.map(\.dayNumber))
    }

    func testPastTodayAndFutureStatuses() {
        let dto = WorkoutsResponseDTO(data: [
            DayDTO(id: "d0", day: 0, assignments: [
                AssignmentDTO(id: "past", title: "Legs day", status: 1, totalExercise: 5)
            ]),
            DayDTO(id: "d2", day: 2, assignments: [
                AssignmentDTO(id: "today", title: "Today work", status: 0, totalExercise: 3)
            ]),
            DayDTO(id: "d6", day: 6, assignments: [
                AssignmentDTO(id: "future", title: "Squat, press, power clean", status: 2, totalExercise: 6)
            ])
        ])

        let mapped = WorkoutMapping.map(dto: dto, weekDays: weekDays, resolver: resolver)
        XCTAssertEqual(mapped[0].workouts.first?.displayStatus, .missed)
        XCTAssertEqual(mapped[2].workouts.first?.displayStatus, .assigned)
        XCTAssertEqual(mapped[6].workouts.first?.displayStatus, .future)
        XCTAssertEqual(mapped[6].workouts.first?.isCompleted, true)
        XCTAssertFalse(mapped[6].workouts.first?.isTappable ?? true)
    }

    func testOverrideWinsOverAPISeed() {
        let dto = WorkoutsResponseDTO(data: [
            DayDTO(id: "d1", day: 1, assignments: [
                AssignmentDTO(id: "warm", title: "Full warm up workout", status: 2, totalExercise: 6)
            ])
        ])

        let withoutOverride = WorkoutMapping.map(dto: dto, weekDays: weekDays, resolver: resolver)
        XCTAssertEqual(withoutOverride[1].workouts.first?.isCompleted, true)
        XCTAssertEqual(withoutOverride[1].workouts.first?.displayStatus, .completed)

        let withOverride = WorkoutMapping.map(
            dto: dto,
            weekDays: weekDays,
            resolver: resolver,
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

        let mapped = WorkoutMapping.map(dto: dto, weekDays: weekDays, resolver: resolver)
        XCTAssertEqual(mapped[0].workouts.first?.isCompleted, false)
    }
}

final class WorkoutDisplayStatusTests: XCTestCase {

    func testMetaText() {
        XCTAssertEqual(WorkoutDisplayStatus.missed.metaText(exerciseCount: 5), "Missed • 5 exercises")
        XCTAssertEqual(WorkoutDisplayStatus.assigned.metaText(exerciseCount: 7), "7 exercises")
        XCTAssertEqual(WorkoutDisplayStatus.completed.metaText(exerciseCount: 6), "Completed")
        XCTAssertEqual(WorkoutDisplayStatus.future.metaText(exerciseCount: 6), "6 exercises")
    }
}
