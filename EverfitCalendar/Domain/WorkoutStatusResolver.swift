//
//  WorkoutStatusResolver.swift
//  EverfitCalendar
//

import Foundation

/// Pure date-vs-completion rules. Inject `today` and `calendar` for tests.
struct WorkoutStatusResolver: Equatable {
    var today: Date
    var calendar: Calendar

    /// Derives UI status from calendar day vs `today`, then local completion.
    /// Priority (first match wins):
    /// 1. `date` after today → `.future` (even if `isCompleted` is true)
    /// 2. `isCompleted` → `.completed` (past or today)
    /// 3. same calendar day as today → `.assigned`
    /// 4. otherwise past incomplete → `.missed`
    /// Day comparisons use `startOfDay` in `calendar` so 00:01 and 23:59 are the same day.
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
