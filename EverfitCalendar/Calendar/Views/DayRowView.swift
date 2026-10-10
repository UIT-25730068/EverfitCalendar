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
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = CalendarStyle.dateFont
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    private let dateHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = CalendarStyle.weekdayToDateSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let workoutStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CalendarStyle.workoutStackSpacing
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = CalendarStyle.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
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

        rebuildWorkoutArea(showsPlaceholder: showsPlaceholder)
    }

    private func setupLayout() {
        dateHeaderStack.addArrangedSubview(weekdayLabel)
        dateHeaderStack.addArrangedSubview(dateLabel)

        let contentStack = UIStackView(arrangedSubviews: [dateHeaderStack, workoutStack])
        contentStack.axis = .horizontal
        contentStack.alignment = .top
        contentStack.spacing = CalendarStyle.dateWorkoutSpacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStack)
        addSubview(separator)

        NSLayoutConstraint.activate([
            dateHeaderStack.widthAnchor.constraint(equalToConstant: CalendarStyle.dateHeaderWidth),

            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: CalendarStyle.rowVerticalPadding),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -CalendarStyle.rowVerticalPadding),

            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: CalendarStyle.hairlineWidth)
        ])

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func rebuildWorkoutArea(showsPlaceholder: Bool) {
        workoutStack.arrangedSubviews.forEach { view in
            workoutStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard showsPlaceholder else { return }

        let placeholder = UIView()
        placeholder.backgroundColor = CalendarStyle.placeholderFill
        placeholder.layer.cornerRadius = CalendarStyle.placeholderCornerRadius
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.heightAnchor.constraint(equalToConstant: CalendarStyle.placeholderHeight).isActive = true
        workoutStack.addArrangedSubview(placeholder)
    }
}
