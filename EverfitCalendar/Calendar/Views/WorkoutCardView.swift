//
//  WorkoutCardView.swift
//  EverfitCalendar
//

import UIKit

final class WorkoutCardView: UIView {

    var onTap: ((String) -> Void)?

    private var workoutID: String?
    private var allowsToggle = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = CalendarStyle.cardTitleFont
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = CalendarStyle.cardMetaFont
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let checkmarkBadge: UIView = {
        let badge = UIView()
        badge.backgroundColor = .white
        badge.layer.cornerRadius = 12
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.setContentHuggingPriority(.required, for: .horizontal)
        badge.setContentCompressionResistancePriority(.required, for: .horizontal)
        return badge
    }()

    private let checkmarkView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        imageView.image = UIImage(systemName: "checkmark", withConfiguration: config)
        imageView.preferredSymbolConfiguration = config
        imageView.tintColor = CalendarStyle.completedCardBackground
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        layer.cornerRadius = CalendarStyle.cardCornerRadius
        clipsToBounds = true
        setupLayout()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ workout: Workout) {
        workoutID = workout.id
        allowsToggle = workout.isTappable
        isUserInteractionEnabled = true
        accessibilityTraits = workout.isTappable ? [.button] : [.staticText]
        accessibilityLabel = workout.title
        accessibilityHint = workout.isTappable ? "Marks the workout complete or incomplete" : nil
        titleLabel.text = workout.title
        applyStyle(for: workout.displayStatus, exerciseCount: workout.exerciseCount)
        setNeedsLayout()
    }

    @objc private func handleTap() {
        guard allowsToggle, let workoutID else { return }
        onTap?(workoutID)
    }

    private func applyStyle(for status: WorkoutDisplayStatus, exerciseCount: Int) {
        let showCheckmark = status == .completed
        checkmarkBadge.isHidden = !showCheckmark
        metaLabel.attributedText = WorkoutMetaFormatting.attributedText(
            status: status,
            exerciseCount: exerciseCount,
            font: CalendarStyle.cardMetaFont
        )

        switch status {
        case .missed:
            backgroundColor = CalendarStyle.cardBackground
            titleLabel.textColor = CalendarStyle.dateColor
        case .assigned:
            backgroundColor = CalendarStyle.cardBackground
            titleLabel.textColor = CalendarStyle.dateColor
        case .completed:
            backgroundColor = CalendarStyle.completedCardBackground
            titleLabel.textColor = CalendarStyle.completedTextColor
            checkmarkView.tintColor = CalendarStyle.completedCardBackground
        case .future:
            backgroundColor = CalendarStyle.cardBackground
            titleLabel.textColor = CalendarStyle.futureTextColor
        }
    }

    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = CalendarStyle.cardTitleMetaSpacing
        textStack.alignment = .fill
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        checkmarkBadge.addSubview(checkmarkView)

        let content = UIStackView(arrangedSubviews: [textStack, checkmarkBadge])
        content.axis = .horizontal
        content.alignment = .center
        content.spacing = 8
        content.insetsLayoutMarginsFromSafeArea = false
        content.translatesAutoresizingMaskIntoConstraints = false

        addSubview(content)

        let insets = CalendarStyle.cardContentInsets
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
            checkmarkBadge.widthAnchor.constraint(equalToConstant: 24),
            checkmarkBadge.heightAnchor.constraint(equalToConstant: 24),
            checkmarkView.centerXAnchor.constraint(equalTo: checkmarkBadge.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: checkmarkBadge.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: 13),
            checkmarkView.heightAnchor.constraint(equalToConstant: 13)
        ])
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
}
