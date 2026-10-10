//
//  WorkoutStatusResolver.swift
//  EverfitCalendar
//

import Foundation

/// Pure date-vs-completion rules. Inject `today` and `calendar` for tests.
struct WorkoutStatusResolver: Equatable {
    var today: Date
    var calendar: Calendar

    func resolve(date: Date, isCompleted: Bool) -> WorkoutDisplayStatus {
        let day = calendar.startOfDay(for: date)
        let todayStart = calendar.startOfDay(for: today)

        if day > todayStart {
            return .future
        }
        if isCompleted {
            return .completed
        }
        if calendar.isDate(day, inSameDayAs: todayStart) {
            return .assigned
        }
        return .missed
    }
}
