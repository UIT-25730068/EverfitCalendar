//
//  WorkoutStatusResolver.swift
//  EverfitCalendar
//

import Foundation

enum WorkoutStatusResolver {

    static func resolve(
        date: Date,
        today: Date,
        isCompleted: Bool,
        calendar: Calendar = .current
    ) -> WorkoutDisplayStatus {
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
