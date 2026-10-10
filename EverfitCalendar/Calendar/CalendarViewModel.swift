//
//  CalendarViewModel.swift
//  EverfitCalendar
//

import Foundation
import os

@MainActor
final class CalendarViewModel {

    private let repository: WorkoutsRepository
    private let weekFactory: CalendarWeekFactory
    private let now: () -> Date
    private let calendar: Calendar
    private let logger = Logger(subsystem: "com.ThanhND.EverfitCalendar", category: "Calendar")

    private var loadTask: Task<Void, Never>?
    private var lastDTO: WorkoutsResponseDTO?
    private var completionOverrides: [String: Bool] = [:]

    var onChange: ((CalendarViewState) -> Void)?

    private(set) var state: CalendarViewState {
        didSet { onChange?(state) }
    }

    init(
        repository: WorkoutsRepository = WorkoutsRepository(),
        weekFactory: CalendarWeekFactory = CalendarWeekFactory(),
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.weekFactory = weekFactory
        self.now = now
        self.calendar = calendar
        let days = weekFactory.makeCurrentWeek(for: now(), calendar: calendar)
        state = CalendarViewState(
            days: days,
            phase: .initialLoading,
            errorMessage: nil,
            showsRetry: false
        )
    }

    func load() {
        loadTask?.cancel()

        let days = weekFactory.makeCurrentWeek(for: now(), calendar: calendar)
        let hasPayload = lastDTO != nil
        if hasPayload, let dto = lastDTO {
            state = CalendarViewState(
                days: mappedDays(from: dto, weekDays: days),
                phase: .refreshing,
                errorMessage: nil,
                showsRetry: false
            )
        } else {
            state = CalendarViewState(
                days: days,
                phase: .initialLoading,
                errorMessage: nil,
                showsRetry: false
            )
        }

        loadTask = Task { [weak self] in
            await self?.performLoad()
        }
    }

    private func performLoad() async {
        let result = await repository.refreshWeek()
        guard !Task.isCancelled else { return }

        if result.error?.isCancelled == true {
            return
        }

        let weekDays = weekFactory.makeCurrentWeek(for: now(), calendar: calendar)

        if let dto = result.dto {
            lastDTO = dto
            if let error = result.error {
                logger.error("Showing data from \(String(describing: result.source), privacy: .public) after \(error.localizedDescription, privacy: .public)")
            }
            state = CalendarViewState(
                days: mappedDays(from: dto, weekDays: weekDays),
                phase: .loaded,
                errorMessage: nil,
                showsRetry: false
            )
            return
        }

        logger.error("No workouts available: \(result.error?.localizedDescription ?? "unknown", privacy: .public)")
        state = CalendarViewState(
            days: weekDays,
            phase: .failedEmpty,
            errorMessage: "Couldn't load workouts.",
            showsRetry: true
        )
    }

    func toggleCompletion(id: String) {
        guard lastDTO != nil else { return }
        guard let workout = workout(id: id) else { return }
        guard workout.isTappable else { return }

        completionOverrides[id] = !workout.isCompleted
        publishMappedWeek(phase: state.phase == .initialLoading ? .loaded : state.phase)
    }

    private func publishMappedWeek(phase: DataPhase) {
        guard let dto = lastDTO else { return }
        let weekDays = weekFactory.makeCurrentWeek(for: now(), calendar: calendar)
        state = CalendarViewState(
            days: mappedDays(from: dto, weekDays: weekDays),
            phase: phase,
            errorMessage: nil,
            showsRetry: false
        )
    }

    private func workout(id: String) -> Workout? {
        state.days.lazy.flatMap(\.workouts).first { $0.id == id }
    }

    private func mappedDays(from dto: WorkoutsResponseDTO, weekDays: [CalendarDay]) -> [CalendarDay] {
        let resolver = WorkoutStatusResolver(today: now(), calendar: calendar)
        return WorkoutMapping.map(
            dto: dto,
            weekDays: weekDays,
            resolver: resolver,
            overrides: completionOverrides
        )
    }
}
