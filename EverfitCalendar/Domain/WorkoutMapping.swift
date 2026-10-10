//
//  WorkoutMapping.swift
//  EverfitCalendar
//

import Foundation

enum APIAssignmentCompletion {
    /// Unverified seed from the mock payload: `2` is the likely Completed value
    /// (Tuesday "Full warm up workout"). Isolated so it can change when confirmed.
    static func isCompletedSeed(from apiStatus: Int) -> Bool {
        apiStatus == 2
    }
}

enum WorkoutMapping {

    /// Places each API `DayDTO.day` (0 = Monday … 6 = Sunday) onto `weekDays[index]`.
    /// Out-of-range `day` values are dropped. Missing indexes keep the date header
    /// with an empty workout list.
    /// Completion: `overrides[assignment.id]` wins; otherwise `APIAssignmentCompletion`
    /// (`status == 2` seed). Display status is always resolved from the header date,
    /// never from the raw API int.
    static func map(
        dto: WorkoutsResponseDTO,
        weekDays: [CalendarDay],
        resolver: WorkoutStatusResolver,
        overrides: [String: Bool] = [:]
    ) -> [CalendarDay] {
        var daysByIndex: [Int: DayDTO] = [:]
        for day in dto.data where (0...6).contains(day.day) {
            daysByIndex[day.day] = day
        }

        return weekDays.enumerated().map { index, header in
            let assignments = daysByIndex[index]?.assignments ?? []
            let workouts = assignments.map { assignment -> Workout in
                let seeded = APIAssignmentCompletion.isCompletedSeed(from: assignment.status)
                let isCompleted = overrides[assignment.id] ?? seeded
                return Workout(
                    id: assignment.id,
                    title: assignment.title,
                    exerciseCount: assignment.totalExercise,
                    isCompleted: isCompleted,
                    displayStatus: resolver.resolve(date: header.date, isCompleted: isCompleted)
                )
            }

            return CalendarDay(
                date: header.date,
                dayNumber: header.dayNumber,
                weekdayShort: header.weekdayShort,
                isToday: header.isToday,
                workouts: workouts
            )
        }
    }
}
