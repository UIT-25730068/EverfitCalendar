//
//  WorkoutCardView.swift
//  EverfitCalendar
//

import UIKit

final class WorkoutCardView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = CalendarStyle.cardTitleFont
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = CalendarStyle.cardMetaFont
        label.numberOfLines = 1
        return label
    }()

    private let checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = CalendarStyle.cardCornerRadius
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ workout: Workout) {
        titleLabel.text = workout.title
        isUserInteractionEnabled = workout.isTappable

        switch workout.displayStatus {
        case .missed:
            backgroundColor = CalendarStyle.cardBackground
            titleLabel.textColor = CalendarStyle.dateColor
            metaLabel.textColor = CalendarStyle.missedTextColor
            metaLabel.text = "Missed • \(workout.exerciseCount) exercises"
            checkmarkView.isHidden = true
        case .assigned:
            backgroundColor = CalendarStyle.cardBackground
            titleLabel.textColor = CalendarStyle.dateColor
            metaLabel.textColor = CalendarStyle.assignedMetaColor
            metaLabel.text = "\(workout.exerciseCount) exercises"
            checkmarkView.isHidden = true
        case .completed:
            backgroundColor = CalendarStyle.completedCardBackground
            titleLabel.textColor = CalendarStyle.completedTextColor
            metaLabel.textColor = CalendarStyle.completedTextColor.withAlphaComponent(0.9)
            metaLabel.text = "Completed"
            checkmarkView.tintColor = CalendarStyle.completedTextColor
            checkmarkView.isHidden = false
        case .future:
            backgroundColor = CalendarStyle.cardBackground
            titleLabel.textColor = CalendarStyle.futureTextColor
            metaLabel.textColor = CalendarStyle.futureTextColor
            metaLabel.text = "\(workout.exerciseCount) exercises"
            checkmarkView.isHidden = true
        }
    }

    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = CalendarStyle.cardTitleMetaSpacing
        textStack.alignment = .fill

        let content = UIStackView(arrangedSubviews: [textStack, checkmarkView])
        content.axis = .horizontal
        content.alignment = .center
        content.spacing = 8
        content.translatesAutoresizingMaskIntoConstraints = false

        addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor, constant: CalendarStyle.cardContentInsets.top),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CalendarStyle.cardContentInsets.left),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CalendarStyle.cardContentInsets.right),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CalendarStyle.cardContentInsets.bottom),
            checkmarkView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkView.heightAnchor.constraint(equalToConstant: 20)
        ])
        checkmarkView.setContentHuggingPriority(.required, for: .horizontal)
        checkmarkView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
