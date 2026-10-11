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
        stack.setContentHuggingPriority(.required, for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
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
        stack.setContentHuggingPriority(.defaultLow, for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = CalendarStyle.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var onWorkoutTap: ((String) -> Void)?

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

    func configure(
        day: CalendarDay,
        hidesWorkoutStack: Bool,
        workoutAlpha: CGFloat
    ) {
        let accent = day.isToday ? CalendarStyle.todayColor : CalendarStyle.weekdayColor
        weekdayLabel.attributedText = NSAttributedString(
            string: day.weekdayShort.uppercased(),
            attributes: [
                .font: CalendarStyle.weekdayFont,
                .foregroundColor: accent,
                .kern: CalendarStyle.weekdayKern
            ]
        )
        dateLabel.text = day.dayNumber
        dateLabel.textColor = day.isToday ? CalendarStyle.todayColor : CalendarStyle.dateColor
        separator.isHidden = false

        UIView.performWithoutAnimation {
            rebuildWorkoutArea(
                workouts: hidesWorkoutStack ? [] : day.workouts
            )
            workoutStack.alpha = hidesWorkoutStack ? 0 : workoutAlpha
            workoutStack.isUserInteractionEnabled = !hidesWorkoutStack
            layoutIfNeeded()
        }
    }

    private func setupLayout() {
        dateHeaderStack.addArrangedSubview(weekdayLabel)
        dateHeaderStack.addArrangedSubview(dateLabel)

        addSubview(dateHeaderStack)
        addSubview(workoutStack)
        addSubview(separator)

        let workoutBottom = workoutStack.bottomAnchor.constraint(
            equalTo: separator.topAnchor,
            constant: -CalendarStyle.rowVerticalPadding
        )
        workoutBottom.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            dateHeaderStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateHeaderStack.topAnchor.constraint(equalTo: topAnchor, constant: CalendarStyle.rowVerticalPadding),
            dateHeaderStack.widthAnchor.constraint(equalToConstant: CalendarStyle.dateHeaderWidth),
            dateHeaderStack.bottomAnchor.constraint(
                lessThanOrEqualTo: separator.topAnchor,
                constant: -CalendarStyle.rowVerticalPadding
            ),

            workoutStack.leadingAnchor.constraint(
                equalTo: dateHeaderStack.trailingAnchor,
                constant: CalendarStyle.dateWorkoutSpacing
            ),
            workoutStack.topAnchor.constraint(equalTo: topAnchor, constant: CalendarStyle.rowVerticalPadding),
            workoutStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            workoutBottom,

            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: CalendarStyle.hairlineWidth),
            heightAnchor.constraint(greaterThanOrEqualToConstant: CalendarStyle.emptyRowMinHeight)
        ])

        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }

    private func rebuildWorkoutArea(workouts: [Workout]) {
        while cardViews.count < workouts.count {
            let card = WorkoutCardView()
            card.onTap = { [weak self] id in
                self?.onWorkoutTap?(id)
            }
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
