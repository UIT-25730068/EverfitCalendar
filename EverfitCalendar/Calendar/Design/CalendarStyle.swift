//
//  CalendarStyle.swift
//  EverfitCalendar
//

import UIKit

enum CalendarStyle {

    // MARK: Colors (from Figma training screens)

    static let screenBackground = UIColor.white
    static let titleColor = UIColor(red: 0.62, green: 0.62, blue: 0.66, alpha: 1)
    static let weekdayColor = UIColor(red: 0.20, green: 0.17, blue: 0.34, alpha: 1)
    static let dateColor = UIColor(red: 0.20, green: 0.17, blue: 0.34, alpha: 1)
    static let todayColor = UIColor(red: 0.45, green: 0.38, blue: 0.96, alpha: 1)
    static let placeholderFill = UIColor(red: 0.96, green: 0.95, blue: 0.99, alpha: 1)
    static let separatorColor = UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1)
    static let cardBackground = UIColor(red: 0.96, green: 0.95, blue: 0.99, alpha: 1)
    static let completedCardBackground = UIColor(red: 0.45, green: 0.38, blue: 0.96, alpha: 1)
    static let missedTextColor = UIColor(red: 0.95, green: 0.43, blue: 0.40, alpha: 1)
    static let assignedMetaColor = UIColor(red: 0.55, green: 0.53, blue: 0.62, alpha: 1)
    static let futureTextColor = UIColor(red: 0.73, green: 0.73, blue: 0.76, alpha: 1)
    static let completedTextColor = UIColor.white
    static let errorTextColor = UIColor(red: 0.45, green: 0.43, blue: 0.55, alpha: 1)
    static let retryTintColor = UIColor(red: 0.45, green: 0.38, blue: 0.96, alpha: 1)

    // MARK: Spacing

    static let screenTopPadding: CGFloat = 8
    static let screenBottomPadding: CGFloat = 8
    static let titleToGridSpacing: CGFloat = 12
    static let dateHeaderWidth: CGFloat = 52
    static let dateWorkoutSpacing: CGFloat = 12
    static let rowVerticalPadding: CGFloat = 18
    static let weekdayToDateSpacing: CGFloat = 2
    static let workoutStackSpacing: CGFloat = 10
    static let emptyRowMinHeight: CGFloat = 88
    static let compactHorizontalPadding: CGFloat = 20
    static let regularHorizontalPadding: CGFloat = 40
    static let regularMaxContentWidth: CGFloat = 720

    static let placeholderHeight: CGFloat = 72
    static let placeholderCornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 16
    static let cardContentInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    static let cardTitleMetaSpacing: CGFloat = 4
    static let weekdayKern: CGFloat = 0.8

    static let hairlineWidth: CGFloat = 1.0 / 3.0

    // MARK: Typography

    static let titleFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    static let weekdayFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
    static let dateFont = UIFont.systemFont(ofSize: 22, weight: .semibold)
    static let cardTitleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static let cardMetaFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    static let errorFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    static let retryFont = UIFont.systemFont(ofSize: 14, weight: .semibold)

    static func horizontalPadding(for traits: UITraitCollection) -> CGFloat {
        traits.horizontalSizeClass == .regular ? regularHorizontalPadding : compactHorizontalPadding
    }
}
