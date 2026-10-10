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
        label.text = "training"
        label.font = CalendarStyle.titleFont
        label.textColor = CalendarStyle.titleColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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
        bindViewModel()
        render(viewModel.state)
        viewModel.load()
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
    }

    private func setupLayout() {
        errorView.isHidden = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, errorView, weekView])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = CalendarStyle.titleToGridSpacing
        stack.setCustomSpacing(8, after: titleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        weekView.setContentHuggingPriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CalendarStyle.screenTopPadding),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CalendarStyle.screenHorizontalPadding),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -CalendarStyle.screenHorizontalPadding),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
