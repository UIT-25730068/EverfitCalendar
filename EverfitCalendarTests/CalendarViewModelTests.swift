//
//  CalendarViewModelTests.swift
//  EverfitCalendarTests
//

import XCTest
@testable import EverfitCalendar

@MainActor
final class CalendarViewModelTests: XCTestCase {

    private var calendar: Calendar!
    private var today: Date!
    private var dto: WorkoutsResponseDTO!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        today = calendar.date(from: DateComponents(year: 2026, month: 10, day: 7, hour: 12))!
        dto = WorkoutsResponseDTO(data: [
            DayDTO(id: "d0", day: 0, assignments: [
                AssignmentDTO(id: "past", title: "Legs day", status: 1, totalExercise: 5)
            ]),
            DayDTO(id: "d2", day: 2, assignments: [
                AssignmentDTO(id: "today", title: "Today work", status: 0, totalExercise: 3)
            ]),
            DayDTO(id: "d6", day: 6, assignments: [
                AssignmentDTO(id: "future", title: "Squat, press, power clean", status: 0, totalExercise: 6)
            ])
        ])
    }

    func testTogglePastWorkoutFlipsCompletedAndDisplayStatus() async {
        let viewModel = makeViewModel()
        await loadAndWait(viewModel)

        XCTAssertEqual(workout(viewModel, id: "past")?.displayStatus, .missed)

        viewModel.toggleCompletion(id: "past")
        XCTAssertEqual(workout(viewModel, id: "past")?.isCompleted, true)
        XCTAssertEqual(workout(viewModel, id: "past")?.displayStatus, .completed)

        viewModel.toggleCompletion(id: "past")
        XCTAssertEqual(workout(viewModel, id: "past")?.isCompleted, false)
        XCTAssertEqual(workout(viewModel, id: "past")?.displayStatus, .missed)
    }

    func testToggleTodayWorkoutBecomesCompletedThenAssigned() async {
        let viewModel = makeViewModel()
        await loadAndWait(viewModel)

        viewModel.toggleCompletion(id: "today")
        XCTAssertEqual(workout(viewModel, id: "today")?.displayStatus, .completed)

        viewModel.toggleCompletion(id: "today")
        XCTAssertEqual(workout(viewModel, id: "today")?.displayStatus, .assigned)
    }

    func testToggleFutureWorkoutIsIgnored() async {
        let viewModel = makeViewModel()
        await loadAndWait(viewModel)

        let before = workout(viewModel, id: "future")
        viewModel.toggleCompletion(id: "future")
        let after = workout(viewModel, id: "future")

        XCTAssertEqual(before?.isCompleted, false)
        XCTAssertEqual(after?.displayStatus, .future)
        XCTAssertEqual(after?.isCompleted, before?.isCompleted)
        XCTAssertFalse(after?.isTappable ?? true)
    }

    func testReloadKeepsInMemoryOverride() async {
        let viewModel = makeViewModel()
        await loadAndWait(viewModel)

        viewModel.toggleCompletion(id: "past")
        XCTAssertEqual(workout(viewModel, id: "past")?.displayStatus, .completed)

        await loadAndWait(viewModel)
        XCTAssertEqual(workout(viewModel, id: "past")?.displayStatus, .completed)
    }

    func testWarmLaunchShowsCacheBeforeNetwork() async {
        let cached = WorkoutsResponseDTO(data: [
            DayDTO(id: "d0", day: 0, assignments: [
                AssignmentDTO(id: "past", title: "Cached legs", status: 1, totalExercise: 5)
            ])
        ])
        let network = WorkoutsResponseDTO(data: [
            DayDTO(id: "d0", day: 0, assignments: [
                AssignmentDTO(id: "past", title: "Network legs", status: 1, totalExercise: 5)
            ])
        ])

        let cache = InMemoryWorkoutsCache()
        try? await cache.save(cached)
        let api = GatedAPI()
        let viewModel = CalendarViewModel(
            repository: WorkoutsRepository(
                api: api,
                fallback: failingFallback(),
                cache: cache,
                completions: InMemoryCompletionStore()
            ),
            now: { [today] in today! },
            calendar: calendar
        )

        let sawCached = expectation(description: "cached")
        sawCached.assertForOverFulfill = false
        let sawNetwork = expectation(description: "network")
        sawNetwork.assertForOverFulfill = false
        viewModel.onChange = { state in
            let title = state.days.flatMap(\.workouts).first(where: { $0.id == "past" })?.title
            if title == "Cached legs", state.phase == .refreshing {
                sawCached.fulfill()
            }
            if title == "Network legs", state.phase == .loaded {
                sawNetwork.fulfill()
            }
        }
        viewModel.load()
        await fulfillment(of: [sawCached], timeout: 1)
        let networkStarted = await waitUntil { api.isWaiting }
        XCTAssertTrue(networkStarted)
        api.resume(.success(network))
        await fulfillment(of: [sawNetwork], timeout: 1)
    }

    func testFailedEmptyShowsRetryAndRetryClearsErrorThenLoads() async {
        let api = GatedAPI()
        let viewModel = CalendarViewModel(
            repository: WorkoutsRepository(
                api: api,
                fallback: failingFallback(),
                cache: InMemoryWorkoutsCache(),
                completions: InMemoryCompletionStore()
            ),
            now: { [today] in today! },
            calendar: calendar
        )

        let failed = expectation(description: "failed")
        failed.assertForOverFulfill = false
        viewModel.onChange = { state in
            if state.phase == .failedEmpty {
                failed.fulfill()
            }
        }
        viewModel.load()
        let fetchStarted = await waitUntil { api.isWaiting }
        XCTAssertTrue(fetchStarted)
        api.resume(.failure(WorkoutsError.network(URLError(.notConnectedToInternet))))
        await fulfillment(of: [failed], timeout: 1)

        XCTAssertEqual(viewModel.state.days.count, 7)
        XCTAssertEqual(viewModel.state.errorMessage, "Couldn't load workouts.")
        XCTAssertTrue(viewModel.state.showsRetry)
        XCTAssertFalse(viewModel.state.showsWorkoutPlaceholders)

        let loading = expectation(description: "retry loading")
        loading.assertForOverFulfill = false
        let loaded = expectation(description: "retry loaded")
        loaded.assertForOverFulfill = false
        viewModel.onChange = { state in
            if state.phase == .initialLoading, state.errorMessage == nil {
                loading.fulfill()
            }
            if state.phase == .loaded {
                loaded.fulfill()
            }
        }
        viewModel.load()
        await fulfillment(of: [loading], timeout: 1)
        XCTAssertFalse(viewModel.state.showsRetry)
        XCTAssertTrue(viewModel.state.showsWorkoutPlaceholders)
        let retryFetchStarted = await waitUntil { api.isWaiting }
        XCTAssertTrue(retryFetchStarted)
        api.resume(.success(dto))
        await fulfillment(of: [loaded], timeout: 1)
        XCTAssertNil(viewModel.state.errorMessage)
        XCTAssertEqual(workout(viewModel, id: "past")?.title, "Legs day")
    }

    func testRefreshFailureWithCacheDoesNotShowError() async {
        let cache = InMemoryWorkoutsCache()
        try? await cache.save(dto)
        let viewModel = CalendarViewModel(
            repository: WorkoutsRepository(
                api: StubAPI(result: .failure(WorkoutsError.httpStatus(500))),
                fallback: failingFallback(),
                cache: cache,
                completions: InMemoryCompletionStore()
            ),
            now: { [today] in today! },
            calendar: calendar
        )

        await loadAndWait(viewModel)
        XCTAssertEqual(viewModel.state.phase, .loaded)
        XCTAssertNil(viewModel.state.errorMessage)
        XCTAssertFalse(viewModel.state.showsRetry)
        XCTAssertEqual(workout(viewModel, id: "past")?.title, "Legs day")
    }

    func testTogglePersistsOverrideForNextViewModel() async {
        let cache = InMemoryWorkoutsCache()
        let completions = InMemoryCompletionStore()
        let repository = WorkoutsRepository(
            api: StubAPI(result: .success(dto)),
            fallback: failingFallback(),
            cache: cache,
            completions: completions
        )

        let first = CalendarViewModel(
            repository: repository,
            now: { [today] in today! },
            calendar: calendar
        )
        await loadAndWait(first)
        first.toggleCompletion(id: "past")
        let persisted = await waitUntil { (try? await completions.load())?["past"] == true }
        XCTAssertTrue(persisted)

        let second = CalendarViewModel(
            repository: WorkoutsRepository(
                api: StubAPI(result: .success(dto)),
                fallback: failingFallback(),
                cache: cache,
                completions: completions
            ),
            now: { [today] in today! },
            calendar: calendar
        )
        await loadAndWait(second)
        XCTAssertEqual(workout(second, id: "past")?.displayStatus, .completed)
    }

    private func makeViewModel() -> CalendarViewModel {
        CalendarViewModel(
            repository: WorkoutsRepository(
                api: StubAPI(result: .success(dto)),
                fallback: failingFallback(),
                cache: InMemoryWorkoutsCache(),
                completions: InMemoryCompletionStore()
            ),
            now: { [today] in today! },
            calendar: calendar
        )
    }

    private func failingFallback() -> StubFallback {
        StubFallback(result: .failure(WorkoutsError.fallbackUnavailable(MissingResourceError(name: "none"))))
    }

    private func loadAndWait(_ viewModel: CalendarViewModel) async {
        let loaded = expectation(description: "loaded")
        loaded.assertForOverFulfill = false
        viewModel.onChange = { state in
            if state.phase == .loaded {
                loaded.fulfill()
            }
        }
        viewModel.load()
        await fulfillment(of: [loaded], timeout: 1)
        viewModel.onChange = nil
    }

    private func workout(_ viewModel: CalendarViewModel, id: String) -> Workout? {
        viewModel.state.days.flatMap(\.workouts).first { $0.id == id }
    }
}
