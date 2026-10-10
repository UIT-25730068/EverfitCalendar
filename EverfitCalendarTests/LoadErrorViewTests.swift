//
//  LoadErrorViewTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

@MainActor
final class LoadErrorViewTests: XCTestCase {

    func testHiddenWhenThereIsNoMessage() {
        let view = LoadErrorView()
        view.configure(message: nil, showsRetry: false)
        XCTAssertTrue(view.isHidden)
    }

    func testShowsMessageAndRetryForFailedEmpty() {
        let view = LoadErrorView()
        var retryCount = 0
        view.onRetry = { retryCount += 1 }

        view.configure(message: "Couldn't load workouts.", showsRetry: true)

        XCTAssertFalse(view.isHidden)
        XCTAssertEqual(view.accessibilityIdentifier, "loadErrorView")
        XCTAssertEqual(view.accessibilityLabel, "Couldn't load workouts.")

        guard let retry = view.viewWithAccessibilityIdentifier("retryButton") as? UIButton else {
            return XCTFail("Missing retry button")
        }
        XCTAssertFalse(retry.isHidden)
        XCTAssertTrue(retry.isEnabled)
        retry.sendActions(for: .touchUpInside)
        XCTAssertEqual(retryCount, 1)
    }

    func testHidesRetryWhenRequested() {
        let view = LoadErrorView()
        view.configure(message: "Couldn't load workouts.", showsRetry: false)
        XCTAssertFalse(view.isHidden)
        let retry = view.viewWithAccessibilityIdentifier("retryButton")
        XCTAssertEqual(retry?.isHidden, true)
    }
}

private extension UIView {
    func viewWithAccessibilityIdentifier(_ identifier: String) -> UIView? {
        if accessibilityIdentifier == identifier {
            return self
        }
        for subview in subviews {
            if let match = subview.viewWithAccessibilityIdentifier(identifier) {
                return match
            }
        }
        return nil
    }
}
