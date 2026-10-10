//
//  DayRowView.swift
//  EverfitCalendar
//

import UIKit

final class DayRowView: UIView {

    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = CalendarStyle.weekdayFont
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = CalendarStyle.dateFont
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let dateHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = CalendarStyle.weekdayToDateSpacing
        stack.setContentHuggingPriority(.required, for: .horizontal)
        stack.setContentCompressionResistancePriority(.required, for: .horizontal)
        stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return stack
    }()

    private let workoutStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CalendarStyle.workoutStackSpacing
        stack.alignment = .fill
        stack.distribution = .fill
        stack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return stack
    }()

    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = CalendarStyle.placeholderFill
        view.layer.cornerRadius = CalendarStyle.placeholderCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = CalendarStyle.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var cardViews: [WorkoutCardView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(day: CalendarDay, showsPlaceholder: Bool, showsSeparator: Bool) {
        weekdayLabel.text = day.weekdayShort.uppercased()
        dateLabel.text = day.dayNumber

        let accent = day.isToday ? CalendarStyle.todayColor : CalendarStyle.weekdayColor
        weekdayLabel.textColor = accent
        dateLabel.textColor = day.isToday ? CalendarStyle.todayColor : CalendarStyle.dateColor
        separator.isHidden = !showsSeparator

        rebuildWorkoutArea(workouts: day.workouts, showsPlaceholder: showsPlaceholder)
    }

    private func setupLayout() {
        dateHeaderStack.addArrangedSubview(weekdayLabel)
        dateHeaderStack.addArrangedSubview(dateLabel)
        workoutStack.addArrangedSubview(placeholderView)
        placeholderView.isHidden = true

        let contentStack = UIStackView(arrangedSubviews: [dateHeaderStack, workoutStack])
        contentStack.axis = .horizontal
        contentStack.alignment = .top
        contentStack.distribution = .fill
        contentStack.spacing = CalendarStyle.dateWorkoutSpacing
        contentStack.insetsLayoutMarginsFromSafeArea = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStack)
        addSubview(separator)

        let placeholderHeight = placeholderView.heightAnchor.constraint(
            equalToConstant: CalendarStyle.placeholderHeight
        )
        placeholderHeight.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            dateHeaderStack.widthAnchor.constraint(equalToConstant: CalendarStyle.dateHeaderWidth),

            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: CalendarStyle.rowVerticalPadding),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -CalendarStyle.rowVerticalPadding),

            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: CalendarStyle.hairlineWidth),
            placeholderHeight
        ])

        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }

    private func rebuildWorkoutArea(workouts: [Workout], showsPlaceholder: Bool) {
        placeholderView.isHidden = !showsPlaceholder

        if showsPlaceholder {
            cardViews.forEach { $0.isHidden = true }
            return
        }

        while cardViews.count < workouts.count {
            let card = WorkoutCardView()
            cardViews.append(card)
            workoutStack.addArrangedSubview(card)
        }

        for (index, card) in cardViews.enumerated() {
            if index < workouts.count {
                card.isHidden = false
                card.configure(workouts[index])
            } else {
                card.isHidden = true
            }
        }
    }
}
