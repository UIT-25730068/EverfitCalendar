//
//  CalendarViewState.swift
//  EverfitCalendar
//

import Foundation

enum DataPhase: Equatable {
    /// Dates are visible; workout area shows placeholders. No valid payload yet.
    case initialLoading
    /// A valid week payload is on screen.
    case loaded
    /// A valid week is on screen while a background refresh is in flight.
    case refreshing
    /// No valid payload; user can retry.
    case failedEmpty
}

struct CalendarViewState: Equatable {
    var days: [CalendarDay]
    var phase: DataPhase

    var showsWorkoutPlaceholders: Bool {
        phase == .initialLoading
    }
}
