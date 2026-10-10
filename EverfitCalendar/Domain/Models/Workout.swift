//
//  Workout.swift
//  EverfitCalendar
//

import Foundation

struct Workout: Equatable {
    let id: String
    let title: String
    let exerciseCount: Int
    let isCompleted: Bool
    let displayStatus: WorkoutDisplayStatus

    var isTappable: Bool {
        displayStatus.isTappable
    }
}
