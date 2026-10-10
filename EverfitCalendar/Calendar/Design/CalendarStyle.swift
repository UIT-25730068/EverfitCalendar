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
    static let cardBackground = UIColor(red: 0.96, green: 0.95, blue: 0.99, alpha: 1)
    static let completedCardBackground = UIColor(red: 0.42, green: 0.36, blue: 0.95, alpha: 1)
    static let missedTextColor = UIColor(red: 0.95, green: 0.42, blue: 0.38, alpha: 1)
    static let assignedMetaColor = UIColor(red: 0.45, green: 0.43, blue: 0.55, alpha: 1)
    static let futureTextColor = UIColor(red: 0.75, green: 0.75, blue: 0.78, alpha: 1)
    static let completedTextColor = UIColor.white
    static let errorTextColor = UIColor(red: 0.45, green: 0.43, blue: 0.55, alpha: 1)
    static let retryTintColor = UIColor(red: 0.42, green: 0.36, blue: 0.95, alpha: 1)

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
    static let cardCornerRadius: CGFloat = 12
    static let cardContentInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    static let cardTitleMetaSpacing: CGFloat = 4

    static var hairlineWidth: CGFloat {
        1 / UIScreen.main.scale
    }

    // MARK: Typography

    static let titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let weekdayFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
    static let dateFont = UIFont.systemFont(ofSize: 22, weight: .semibold)
    static let cardTitleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static let cardMetaFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    static let errorFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    static let retryFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
}
