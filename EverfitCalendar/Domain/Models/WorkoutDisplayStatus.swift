//
//  WorkoutDisplayStatus.swift
//  EverfitCalendar
//

import Foundation

enum WorkoutDisplayStatus: Equatable {
    case missed
    case assigned
    case completed
    case future

    /// Future assignments are display-only; missed / assigned / completed may toggle locally.
    var isTappable: Bool {
        self != .future
    }

    func metaText(exerciseCount: Int) -> String {
        switch self {
        case .missed:
            return "Missed • \(exerciseCount) exercises"
        case .completed:
            return "Completed"
        case .assigned, .future:
            return "\(exerciseCount) exercises"
        }
    }
}
