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
        return label
    }()

    private lazy var retryButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Retry"
        configuration.baseForegroundColor = CalendarStyle.retryTintColor
        configuration.contentInsets = .zero
        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = CalendarStyle.retryFont
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [messageLabel, retryButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        retryButton.setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(message: String?, showsRetry: Bool) {
        messageLabel.text = message
        retryButton.isHidden = !showsRetry
        isHidden = message == nil
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}
