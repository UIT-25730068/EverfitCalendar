//
//  CalendarViewModel.swift
//  EverfitCalendar
//

import Foundation

final class CalendarViewModel {

    private let weekFactory: CalendarWeekFactory
    private let now: () -> Date

    var onChange: ((CalendarViewState) -> Void)?

    private(set) var state: CalendarViewState {
        didSet { onChange?(state) }
    }

    init(
        weekFactory: CalendarWeekFactory = CalendarWeekFactory(),
        now: @escaping () -> Date = Date.init
    ) {
        self.weekFactory = weekFactory
        self.now = now
        let days = weekFactory.makeCurrentWeek(for: now())
        state = CalendarViewState(days: days, phase: .initialLoading)
    }
}
