//
//  CalendarStyle.swift
//  EverfitCalendar
//

import UIKit

enum CalendarStyle {

    // MARK: Colors (from Figma training screens)

    static let screenBackground = UIColor.white
    static let titleColor = UIColor(red: 0.62, green: 0.62, blue: 0.66, alpha: 1)
    static let weekdayColor = UIColor(red: 123.0/255.0, green: 126.0/255.0, blue: 145.0/255.0, alpha: 1)
    static let dateColor = UIColor(red: 30.0/255.0, green: 10.0/255.0, blue: 60.0/255.0, alpha: 1)
    static let todayColor = UIColor(red: 116.0/255.0, green: 112.0/255.0, blue: 239.0/255.0, alpha: 1)
    static let placeholderFill = UIColor(red: 0.96, green: 0.95, blue: 0.99, alpha: 1)
    static let separatorColor = UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1)
    static let cardBackground = UIColor(red: 247.0/255.0, green: 248.0/255.0, blue: 252.0/255.0, alpha: 1)
    static let completedCardBackground = UIColor(red: 116.0/255.0, green: 112.0/255.0, blue: 239.0/255.0, alpha: 1)
    static let missedTextColor = UIColor(red: 1, green: 94.0/255.0, blue: 94.0/255.0, alpha: 1)
    static let assignedMetaColor = UIColor(red: 30.0/255.0, green: 10.0/255.0, blue: 60.0/255.0, alpha: 1)
    static let futureTextColor = UIColor(red: 123.0/255.0, green: 126.0/255.0, blue: 145.0/255.0, alpha: 1)
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
    static let cardCornerRadius: CGFloat = 8
    static let cardContentInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    static let cardTitleMetaSpacing: CGFloat = 4
    static let weekdayKern: CGFloat = 0.8

    static let hairlineWidth: CGFloat = 1.0 / 3.0

    // MARK: Typography

    static let titleFont = UIFont.openSansRegular(ofSize: 15)
    static let weekdayFont = UIFont.openSansBold(ofSize: 12)
    static let dateFont = UIFont.openSansRegular(ofSize: 17) // 16
    static let cardTitleFont = UIFont.openSansBold(ofSize: 15)
    static let cardMetaFont = UIFont.openSansRegular(ofSize: 13)
    static let errorFont = UIFont.openSansRegular(ofSize: 14)
    static let retryFont = UIFont.openSansMedium(ofSize: 14)

    static func horizontalPadding(for traits: UITraitCollection) -> CGFloat {
        traits.horizontalSizeClass == .regular ? regularHorizontalPadding : compactHorizontalPadding
    }
}
