//
//  WorkoutMetaFormatting.swift
//  EverfitCalendar
//

import UIKit

enum WorkoutMetaFormatting {

    static let missedPrefix = "Missed"

    static func attributedText(
        status: WorkoutDisplayStatus,
        exerciseCount: Int,
        font: UIFont
    ) -> NSAttributedString {
        let string = status.metaText(exerciseCount: exerciseCount)
        switch status {
        case .missed:
            let attributed = NSMutableAttributedString(
                string: string,
                attributes: [
                    .font: font,
                    .foregroundColor: CalendarStyle.assignedMetaColor
                ]
            )
            let prefixRange = (string as NSString).range(of: missedPrefix)
            if prefixRange.location != NSNotFound {
                attributed.addAttribute(
                    .foregroundColor,
                    value: CalendarStyle.missedTextColor,
                    range: prefixRange
                )
            }
            return attributed
        case .assigned:
            return NSAttributedString(
                string: string,
                attributes: [
                    .font: font,
                    .foregroundColor: CalendarStyle.assignedMetaColor
                ]
            )
        case .completed:
            return NSAttributedString(
                string: string,
                attributes: [
                    .font: font,
                    .foregroundColor: CalendarStyle.completedTextColor.withAlphaComponent(0.9)
                ]
            )
        case .future:
            return NSAttributedString(
                string: string,
                attributes: [
                    .font: font,
                    .foregroundColor: CalendarStyle.futureTextColor
                ]
            )
        }
    }
}
