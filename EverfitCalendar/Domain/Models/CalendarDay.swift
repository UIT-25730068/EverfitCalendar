//
//  CalendarDay.swift
//  EverfitCalendar
//

import Foundation

struct CalendarDay: Equatable {
    let date: Date
    /// Day of month, e.g. `"10"`.
    let dayNumber: String
    /// Short weekday name, e.g. `"Mon"`.
    let weekdayShort: String
    let isToday: Bool
}
