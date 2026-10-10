//
//  UIFont+OpenSans.swift
//  EverfitCalendar
//

import UIKit

extension UIFont {

    private enum OpenSans {
        case regular
        case medium
        case bold

        var postScriptName: String {
            switch self {
            case .regular: "OpenSans-Regular"
            case .medium: "OpenSans-Medium"
            case .bold: "OpenSans-Bold"
            }
        }

        var displayName: String {
            switch self {
            case .regular: "Open Sans"
            case .medium: "Open Sans Medium"
            case .bold: "Open Sans Bold"
            }
        }

        var systemWeight: UIFont.Weight {
            switch self {
            case .regular: .regular
            case .medium: .medium
            case .bold: .bold
            }
        }
    }

    static func openSansRegular(ofSize size: CGFloat) -> UIFont {
        openSans(.regular, ofSize: size)
    }

    static func openSansMedium(ofSize size: CGFloat) -> UIFont {
        openSans(.medium, ofSize: size)
    }

    static func openSansBold(ofSize size: CGFloat) -> UIFont {
        openSans(.bold, ofSize: size)
    }

    private static func openSans(_ face: OpenSans, ofSize size: CGFloat) -> UIFont {
        if let font = UIFont(name: face.postScriptName, size: size) {
            return font
        }
        if let font = UIFont(name: face.displayName, size: size) {
            return font
        }
        return .systemFont(ofSize: size, weight: face.systemWeight)
    }
}
