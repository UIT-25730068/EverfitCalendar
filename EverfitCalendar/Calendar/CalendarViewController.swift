//
//  CalendarViewController.swift
//  EverfitCalendar
//

import UIKit

final class CalendarViewController: UIViewController {

    private let viewModel: CalendarViewModel
    private let weekView = WeekCalendarView()
    private let errorView = LoadErrorView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(
            string: "training",
            attributes: [
                .font: CalendarStyle.titleFont,
                .foregroundColor: CalendarStyle.titleColor,
                .kern: 0.2
            ]
        )
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let backgroundRefreshIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = CalendarStyle.todayColor
        indicator.hidesWhenStopped = true
        indicator.setContentHuggingPriority(.required, for: .horizontal)
        return indicator
    }()

    private let titleRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = CalendarStyle.titleToGridSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = CalendarStyle.todayColor
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.accessibilityIdentifier = "loadingIndicator"
        return indicator
    }()

    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = CalendarStyle.todayColor
        control.accessibilityIdentifier = "refreshControl"
        return control
    }()

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var maxWidthConstraint: NSLayoutConstraint!

    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = CalendarViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CalendarStyle.screenBackground
        setupLayout()
        applyAdaptiveMetrics()
        bindViewModel()
        render(viewModel.state)
        viewModel.loadWorkouts()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        applyAdaptiveMetrics()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        traitCollection.userInterfaceIdiom == .pad ? .all : .portrait
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] state in
            self?.render(state)
        }
        errorView.onRetry = { [weak self] in
            self?.viewModel.loadWorkouts()
        }
        weekView.onWorkoutTap = { [weak self] id in
            self?.viewModel.toggleCompletion(id: id)
        }
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }

    @objc private func didPullToRefresh() {
        viewModel.refreshWorkouts()
    }

    private func render(_ state: CalendarViewState) {
        weekView.configure(
            days: state.days,
            hidesWorkoutStack: state.hidesWorkoutStack,
            workoutAlpha: CGFloat(state.workoutContentAlpha)
        )
        errorView.configure(message: state.errorMessage, showsRetry: state.showsRetry)
        weekView.accessibilityIdentifier = "weekCalendar"

        if state.showsLoadingIndicator {
            if !loadingIndicator.isAnimating {
                loadingIndicator.startAnimating()
            }
        } else {
            loadingIndicator.stopAnimating()
        }

        if state.showsBackgroundRefreshIndicator {
            if !backgroundRefreshIndicator.isAnimating {
                backgroundRefreshIndicator.startAnimating()
            }
        } else {
            backgroundRefreshIndicator.stopAnimating()
        }

        if state.phase != .refreshing, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    private func setupLayout() {
        errorView.isHidden = true
        titleRow.addArrangedSubview(titleLabel)
        titleRow.addArrangedSubview(backgroundRefreshIndicator)
        contentStack.addArrangedSubview(titleRow)
        contentStack.addArrangedSubview(errorView)
        contentStack.addArrangedSubview(weekView)
        contentStack.setCustomSpacing(8, after: titleRow)
        weekView.setContentHuggingPriority(.defaultLow, for: .vertical)
        weekView.installRefreshControl(refreshControl)

        view.addSubview(contentStack)
        view.addSubview(loadingIndicator)

        let safe = view.safeAreaLayoutGuide
        leadingConstraint = contentStack.leadingAnchor.constraint(
            equalTo: safe.leadingAnchor,
            constant: CalendarStyle.compactHorizontalPadding
        )
        leadingConstraint.priority = .defaultHigh
        trailingConstraint = contentStack.trailingAnchor.constraint(
            equalTo: safe.trailingAnchor,
            constant: -CalendarStyle.compactHorizontalPadding
        )
        trailingConstraint.priority = .defaultHigh
        maxWidthConstraint = contentStack.widthAnchor.constraint(
            lessThanOrEqualToConstant: CalendarStyle.regularMaxContentWidth
        )

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: safe.topAnchor, constant: CalendarStyle.screenTopPadding),
            contentStack.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            contentStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStack.leadingAnchor.constraint(
                greaterThanOrEqualTo: safe.leadingAnchor,
                constant: CalendarStyle.compactHorizontalPadding
            ),
            contentStack.trailingAnchor.constraint(
                lessThanOrEqualTo: safe.trailingAnchor,
                constant: -CalendarStyle.compactHorizontalPadding
            ),
            leadingConstraint,
            trailingConstraint,
            maxWidthConstraint,

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func applyAdaptiveMetrics() {
        let padding = CalendarStyle.horizontalPadding(for: traitCollection)
        leadingConstraint.constant = padding
        trailingConstraint.constant = -padding
        maxWidthConstraint.isActive = traitCollection.userInterfaceIdiom == .pad
    }
}
