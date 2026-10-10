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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = CalendarStyle.titleToGridSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        viewModel.load()
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
            self?.viewModel.load()
        }
        weekView.onWorkoutTap = { [weak self] id in
            self?.viewModel.toggleCompletion(id: id)
        }
    }

    private func render(_ state: CalendarViewState) {
        weekView.configure(days: state.days, showsPlaceholders: state.showsWorkoutPlaceholders)
        errorView.configure(message: state.errorMessage, showsRetry: state.showsRetry)
        weekView.accessibilityIdentifier = "weekCalendar"
    }

    private func setupLayout() {
        errorView.isHidden = true
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(errorView)
        contentStack.addArrangedSubview(weekView)
        contentStack.setCustomSpacing(8, after: titleLabel)
        weekView.setContentHuggingPriority(.defaultLow, for: .vertical)

        view.addSubview(contentStack)

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
            maxWidthConstraint
        ])
    }

    private func applyAdaptiveMetrics() {
        let padding = CalendarStyle.horizontalPadding(for: traitCollection)
        leadingConstraint.constant = padding
        trailingConstraint.constant = -padding
        maxWidthConstraint.isActive = traitCollection.userInterfaceIdiom == .pad
    }
}
