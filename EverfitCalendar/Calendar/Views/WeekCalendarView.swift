//
//  WeekCalendarView.swift
//  EverfitCalendar
//

import UIKit

final class WeekCalendarView: UIView {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.insetsLayoutMarginsFromSafeArea = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0
        stack.insetsLayoutMarginsFromSafeArea = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    var onWorkoutTap: ((String) -> Void)?

    private let rows: [DayRowView] = (0..<7).map { _ in DayRowView() }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        rows.forEach { row in
            row.onWorkoutTap = { [weak self] id in
                self?.onWorkoutTap?(id)
            }
            stackView.addArrangedSubview(row)
        }
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(days: [CalendarDay], showsPlaceholders: Bool) {
        for (index, row) in rows.enumerated() {
            guard days.indices.contains(index) else {
                row.isHidden = true
                continue
            }
            row.isHidden = false
            row.configure(
                day: days[index],
                showsPlaceholder: showsPlaceholders,
                showsSeparator: true
            )
        }
    }

    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        let contentLayout = scrollView.contentLayoutGuide
        let frameLayout = scrollView.frameLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: contentLayout.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayout.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
