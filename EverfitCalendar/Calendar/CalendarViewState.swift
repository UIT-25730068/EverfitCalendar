//
//  CalendarViewState.swift
//  EverfitCalendar
//

import Foundation

enum DataPhase: Equatable {
    /// Reading disk before deciding between a warm launch and a cold load.
    case checkingCache
    /// Dates only; large spinner. No workout cards or fallback while the first network attempt is in flight.
    case initialLoading
    /// A valid week payload is on screen.
    case loaded
    /// Cached cards stay on screen while a network refresh is in flight.
    case refreshing
    /// No valid payload; user can retry.
    case failedEmpty
}

struct CalendarViewState: Equatable {
    var days: [CalendarDay]
    var phase: DataPhase
    var errorMessage: String?
    var showsRetry: Bool
    var isUserRefresh: Bool

    var showsLoadingIndicator: Bool {
        phase == .initialLoading
    }

    /// True only when every day has zero workouts (cold start / empty error).
    /// Presence of cached cards, not `DataPhase`, decides visibility during refresh.
    var hidesWorkoutStack: Bool {
        days.allSatisfy(\.workouts.isEmpty)
    }

    var showsBackgroundRefreshIndicator: Bool {
        phase == .refreshing && !isUserRefresh
    }

    var workoutContentAlpha: Double {
        1
    }
}
