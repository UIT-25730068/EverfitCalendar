//
//  CalendarStyle.swift
//  EverfitCalendar
//

import UIKit

enum CalendarStyle {

    // MARK: Colors (from Figma training screens)

    static let screenBackground = UIColor.white
    static let titleColor = UIColor(red: 0.62, green: 0.62, blue: 0.65, alpha: 1)
    static let weekdayColor = UIColor(red: 0.18, green: 0.16, blue: 0.33, alpha: 1)
    static let dateColor = UIColor(red: 0.18, green: 0.16, blue: 0.33, alpha: 1)
    static let todayColor = UIColor(red: 0.42, green: 0.36, blue: 0.95, alpha: 1)
    static let placeholderFill = UIColor(red: 0.96, green: 0.95, blue: 0.99, alpha: 1)
    static let separatorColor = UIColor(red: 0.93, green: 0.93, blue: 0.94, alpha: 1)

    // MARK: Spacing

    static let screenHorizontalPadding: CGFloat = 16
    static let screenTopPadding: CGFloat = 12
    static let screenBottomPadding: CGFloat = 8
    static let titleToGridSpacing: CGFloat = 16
    static let dateHeaderWidth: CGFloat = 56
    static let dateWorkoutSpacing: CGFloat = 12
    static let rowVerticalPadding: CGFloat = 16
    static let weekdayToDateSpacing: CGFloat = 2
    static let workoutStackSpacing: CGFloat = 8

    static let placeholderHeight: CGFloat = 72
    static let placeholderCornerRadius: CGFloat = 12

    static var hairlineWidth: CGFloat {
        1 / UIScreen.main.scale
    }

    // MARK: Typography

    static let titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let weekdayFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
    static let dateFont = UIFont.systemFont(ofSize: 22, weight: .semibold)
}
