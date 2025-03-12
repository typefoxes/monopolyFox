//
//  MoneyInputView.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 08.03.2025.
//

import UIKit

protocol MoneyInputDelegate: AnyObject {
    /// Изменились данные ввода
    func moneyValueChanged()
}

final class MoneyInputView: UIView {

    // MARK: - Constants

    private enum Constants {
        static var textFieldFont: UIFont = UIDevice.isPad ? UIFont.systemFont(ofSize: 13) : UIFont.systemFont(ofSize: 9)
        static let currencyLabel: String = "k"
        static let amount: String = "Amount"
        static let stackSpacing: CGFloat = 8
        static let textFieldMultiplier: CGFloat = 0.8
    }

    // MARK: - Private properties

    private let textField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.font = Constants.textFieldFont
        textField.borderStyle = .roundedRect
        textField.placeholder = Constants.amount
        return textField
    }()

    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.currencyLabel
        label.font = Constants.textFieldFont
        return label
    }()

    // MARK: - Public properties

    weak var delegate: MoneyInputDelegate?
    var value: Int { Int(textField.text ?? String.empty) ?? .zero }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setup() {
        let stack = UIStackView(arrangedSubviews: [textField, currencyLabel])
        stack.axis = .horizontal
        stack.spacing = Constants.stackSpacing

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.textFieldMultiplier),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    @objc private func textChanged() {
        delegate?.moneyValueChanged()
    }

    // MARK: - Public methods

    func clear() {
        textField.text = nil
    }
}
