//
//  LoadErrorView.swift
//  EverfitCalendar
//

import UIKit

final class LoadErrorView: UIView {

    var onRetry: (() -> Void)?

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = CalendarStyle.errorFont
        label.textColor = CalendarStyle.errorTextColor
        label.numberOfLines = 0
        label.textAlignment = .left
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var retryButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Retry"
        configuration.baseForegroundColor = CalendarStyle.retryTintColor
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = CalendarStyle.retryFont
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "retryButton"
        button.accessibilityLabel = "Retry"
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        accessibilityIdentifier = "loadErrorView"
        backgroundColor = CalendarStyle.placeholderFill
        layer.cornerRadius = CalendarStyle.cardCornerRadius
        clipsToBounds = true

        let stack = UIStackView(arrangedSubviews: [messageLabel, retryButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.insetsLayoutMarginsFromSafeArea = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(message: String?, showsRetry: Bool) {
        messageLabel.text = message
        retryButton.isHidden = !showsRetry
        retryButton.isEnabled = showsRetry
        isHidden = message == nil
        accessibilityLabel = message
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}
