//
//  CalendarViewController.swift
//  EverfitCalendar
//

import UIKit

final class CalendarViewController: UIViewController {

    private let viewModel: CalendarViewModel
    private let weekView = WeekCalendarView()

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
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        traitCollection.userInterfaceIdiom == .pad ? .all : .portrait
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: CalendarViewState) {
        weekView.configure(days: state.days, showsPlaceholders: state.showsWorkoutPlaceholders)
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(weekView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CalendarStyle.screenTopPadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CalendarStyle.screenHorizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -CalendarStyle.screenHorizontalPadding),

            weekView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CalendarStyle.titleToGridSpacing),
            weekView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CalendarStyle.screenHorizontalPadding),
            weekView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -CalendarStyle.screenHorizontalPadding),
            weekView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
