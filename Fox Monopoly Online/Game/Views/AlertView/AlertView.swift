//
//  AlertView.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 10.02.2025.
//

import UIKit

protocol AlertViewDelegate: AnyObject {
    func closeView()
}

final class AlertView: UIView {

    private enum Constants {
        static let titleFontSize: CGFloat = 15
        static let messageFontSize: CGFloat = 12
        static let buttonFontSize: CGFloat = 12
        static let cornerRadius: CGFloat = 5
        static let verticalPadding: CGFloat = 10
        static let horizontalPadding: CGFloat = 10
        static let titleHeight: CGFloat = 20
        static let messageBottomOffset: CGFloat = -30
        static let buttonHeight: CGFloat = 20
        static let buttonBottomPadding: CGFloat = -5
        static let elementSpacing: CGFloat = 5
        static let insufficientFundsTitle = "Недостаточно средств на оплату"
        static let jailTitle = "Вaш ход! Вы находитесь в тюрьме."
    }

    // MARK: - Private properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .greys
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .greys
        label.font = .systemFont(ofSize: Constants.messageFontSize, weight: .regular)
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .acceptButton
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .semibold)
        button.titleLabel?.numberOfLines = .zero
        button.layer.cornerRadius = Constants.cornerRadius
        button.titleLabel?.textColor = .white
        return button
    }()

    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.cornerRadius
        button.titleLabel?.numberOfLines = .zero
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .semibold)
        button.backgroundColor = .greys
        return button
    }()

    //MARK: - Public properties

    weak var delegate: AlertViewDelegate?

    // MARK: - Private functions

    private func setupView(twoButtons: Bool) {
        addSubviews(titleLabel, messageLabel, leftButton)

        if twoButtons {
            addSubview(rightButton)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.titleHeight),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.verticalPadding),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            messageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.titleHeight),
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: Constants.messageBottomOffset)
        ])

        if !twoButtons {
            NSLayoutConstraint.activate([
                leftButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.buttonBottomPadding),
                leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
                leftButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
                leftButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
                leftButton.topAnchor.constraint(greaterThanOrEqualTo: messageLabel.bottomAnchor, constant: Constants.elementSpacing)
            ])
        } else {
            NSLayoutConstraint.activate([
                leftButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.buttonBottomPadding),
                leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
                leftButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -Constants.elementSpacing),
                leftButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
                leftButton.topAnchor.constraint(greaterThanOrEqualTo: messageLabel.bottomAnchor, constant: Constants.elementSpacing),

                rightButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.buttonBottomPadding),
                rightButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: Constants.elementSpacing),
                rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
                rightButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
                rightButton.topAnchor.constraint(greaterThanOrEqualTo: messageLabel.bottomAnchor, constant: Constants.elementSpacing)
            ])
        }
    }

    // MARK: - Public  functions

    func configureWithOneButton(model: AlertModel) {
        setupView(twoButtons: false)
        backgroundColor = .white

        titleLabel.text = model.title
        messageLabel.text = model.message
        leftButton.setTitle(model.leftButtonTitle, for: .normal)
        leftButton.isEnabled = model.leftButtonSelectable
        leftButton.backgroundColor = model.leftButtonSelectable ? .acceptButton : .lightGray

        if let action = model.actionLeftButton {
            leftButton.addAction(UIAction { [weak self] _ in
                action()
                self?.delegate?.closeView()
            }, for: .touchUpInside)
        }
    }

    func configureWithTwoButton(model: AlertModel) {
        setupView(twoButtons: true)
        backgroundColor = .white

        titleLabel.text = model.title
        messageLabel.text = model.message
        leftButton.setTitle(model.leftButtonTitle, for: .normal)
        leftButton.isEnabled = model.leftButtonSelectable
        leftButton.backgroundColor = model.leftButtonSelectable ? .acceptButton : .lightGray
        rightButton.setTitle(model.rightButtonTitle, for: .normal)
        rightButton.isEnabled = model.rightButtonSelectable
        rightButton.backgroundColor = model.rightButtonSelectable ? .greys : .lightGray

        if let action = model.actionLeftButton {
            leftButton.addAction(UIAction { [weak self] _ in
                action()
                self?.delegate?.closeView()
            }, for: .touchUpInside)
        }

        if let action = model.actionRightButton {
            rightButton.addAction(UIAction { [weak self] _ in
                action()
                self?.delegate?.closeView()
            }, for: .touchUpInside)
        }
    }

    func updatePayButtonInAlert() {
        if let titleText = titleLabel.text, titleText.contains(Constants.insufficientFundsTitle) || titleText.contains(Constants.jailTitle) {
            leftButton.isEnabled = true
            leftButton.backgroundColor = .acceptButton
        }
    }
}

struct AlertModel {
    var title: String
    var message: String
    var leftButtonTitle: String
    var rightButtonTitle: String? = nil
    var actionLeftButton: (() -> Void)? = nil
    var actionRightButton: (() -> Void)? = nil
    var leftButtonSelectable: Bool = true
    var rightButtonSelectable: Bool = true
}
