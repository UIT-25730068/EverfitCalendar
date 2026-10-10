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

    private let checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle")
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        metaLabel.text = workout.displayStatus.metaText(exerciseCount: workout.exerciseCount)
        applyStyle(for: workout.displayStatus)
        setNeedsLayout()
    }

    @objc private func handleTap() {
        guard allowsToggle, let workoutID else { return }
        onTap?(workoutID)
    }

    private func applyStyle(for status: WorkoutDisplayStatus) {
        let showCheckmark = status == .completed
        checkmarkView.isHidden = !showCheckmark

        switch status {
        case .missed:
            backgroundColor = CalendarStyle.cardBackground
            titleLabel.textColor = CalendarStyle.dateColor
            metaLabel.textColor = CalendarStyle.missedTextColor
        case .assigned:
            backgroundColor = CalendarStyle.cardBackground
            titleLabel.textColor = CalendarStyle.dateColor
            metaLabel.textColor = CalendarStyle.assignedMetaColor
        case .completed:
            backgroundColor = CalendarStyle.completedCardBackground
            titleLabel.textColor = CalendarStyle.completedTextColor
            metaLabel.textColor = CalendarStyle.completedTextColor.withAlphaComponent(0.9)
            checkmarkView.tintColor = CalendarStyle.completedTextColor
        case .future:
            backgroundColor = CalendarStyle.cardBackground
            titleLabel.textColor = CalendarStyle.futureTextColor
            metaLabel.textColor = CalendarStyle.futureTextColor
        }
    }

    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = CalendarStyle.cardTitleMetaSpacing
        textStack.alignment = .fill
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let content = UIStackView(arrangedSubviews: [textStack, checkmarkView])
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
            checkmarkView.widthAnchor.constraint(equalToConstant: 22),
            checkmarkView.heightAnchor.constraint(equalToConstant: 22)
        ])
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
}
