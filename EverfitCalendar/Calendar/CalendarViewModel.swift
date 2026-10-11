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
    private var lastSource: WorkoutDataSource = .none
    private var completionOverrides: [String: Bool] = [:]
    private var isUserRefresh = false

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
        state = CalendarViewState(
            days: weekFactory.makeCurrentWeek(for: now(), calendar: calendar),
            phase: .checkingCache,
            errorMessage: nil,
            showsRetry: false,
            isUserRefresh: false
        )
    }

    func loadWorkouts() {
        loadTask?.cancel()
        isUserRefresh = false

        if hasPresentableServerData {
            publishMappedWeek(phase: .refreshing)
        } else if state.phase != .checkingCache {
            lastDTO = nil
            lastSource = .none
            state = CalendarViewState(
                days: weekFactory.makeCurrentWeek(for: now(), calendar: calendar),
                phase: .initialLoading,
                errorMessage: nil,
                showsRetry: false,
                isUserRefresh: false
            )
        }

        loadTask = Task { [weak self] in
            await self?.performLoad()
        }
    }

    func refreshWorkouts() {
        loadTask?.cancel()
        isUserRefresh = true

        if hasPresentableServerData {
            publishMappedWeek(phase: .refreshing)
        } else if state.phase != .checkingCache {
            lastDTO = nil
            lastSource = .none
            state = CalendarViewState(
                days: weekFactory.makeCurrentWeek(for: now(), calendar: calendar),
                phase: .initialLoading,
                errorMessage: nil,
                showsRetry: false,
                isUserRefresh: true
            )
        }

        loadTask = Task { [weak self] in
            await self?.performLoad()
        }
    }

    /// Whether a cache or network payload is on hand for mapping.
    /// Local mark/unmark only writes `completionOverrides` and must not clear this,
    /// otherwise pull-to-refresh would skip a normal refresh and look like a cold start.
    private var hasPresentableServerData: Bool {
        lastDTO != nil && (lastSource == .cache || lastSource == .network)
    }

    private func performLoad() async {
        let snapshot = await repository.loadCachedSnapshot()
        guard !Task.isCancelled, snapshot.error?.isCancelled != true else { return }

        completionOverrides = snapshot.overrides.merging(completionOverrides) { _, current in current }

        if let dto = snapshot.dto {
            lastDTO = dto
            lastSource = .cache
            publishMappedWeek(phase: .refreshing)
        } else if lastDTO == nil {
            state = CalendarViewState(
                days: weekFactory.makeCurrentWeek(for: now(), calendar: calendar),
                phase: .initialLoading,
                errorMessage: nil,
                showsRetry: false,
                isUserRefresh: false
            )
        }

        if let cacheError = snapshot.error {
            logger.error("Cache snapshot issue: \(cacheError.localizedDescription, privacy: .public)")
        }

        let result = await repository.refreshWeek()
        guard !Task.isCancelled else { return }
        if result.error?.isCancelled == true {
            return
        }

        applyNetworkResult(result)
    }

    private func applyNetworkResult(_ result: WeekLoadResult) {
        if let dto = result.dto {
            lastDTO = dto
            lastSource = result.source

            switch result.source {
            case .fallback:
                logger.error("Network failed; showing bundled fallback: \(result.error?.localizedDescription ?? "unknown", privacy: .public)")
                publishMappedWeek(
                    phase: .loaded,
                    errorMessage: "Couldn't reach the server. Showing sample workouts.",
                    showsRetry: true
                )
            case .cache:
                if result.error != nil {
                    logger.error("Refresh failed; keeping cached week: \(result.error?.localizedDescription ?? "unknown", privacy: .public)")
                }
                publishMappedWeek(phase: .loaded)
            case .network:
                publishMappedWeek(phase: .loaded)
            case .none:
                break
            }
            return
        }

        lastDTO = nil
        lastSource = .none
        logger.error("No workouts available: \(result.error?.localizedDescription ?? "unknown", privacy: .public)")
        state = CalendarViewState(
            days: weekFactory.makeCurrentWeek(for: now(), calendar: calendar),
            phase: .failedEmpty,
            errorMessage: "Couldn't load workouts.",
            showsRetry: true,
            isUserRefresh: false
        )
    }

    func toggleCompletion(id: String) {
        guard lastDTO != nil else { return }
        guard let workout = workout(id: id) else { return }
        guard workout.isTappable else { return }

        let updated = !workout.isCompleted
        completionOverrides[id] = updated
        publishMappedWeek(
            phase: state.phase == .refreshing ? .refreshing : .loaded
        )

        Task { [weak self] in
            await self?.repository.setOverride(id: id, isCompleted: updated)
        }
    }

    private func publishMappedWeek(
        phase: DataPhase,
        errorMessage: String? = nil,
        showsRetry: Bool = false
    ) {
        guard let dto = lastDTO else { return }
        let weekDays = weekFactory.makeCurrentWeek(for: now(), calendar: calendar)
        state = CalendarViewState(
            days: mappedDays(from: dto, weekDays: weekDays),
            phase: phase,
            errorMessage: errorMessage,
            showsRetry: showsRetry,
            isUserRefresh: phase == .refreshing && isUserRefresh
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
