//
//  TradeingView.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 07.02.2025.
//

import UIKit

protocol TradeViewDelegate: AnyObject {
    /// Закрыть вью
    func closeTradeView()
    /// Отправить предложение
    /// - Parameter model: модель предложения
    func proposeTrade(_ model: TradeViewModel)
}

final class TradeView: UIView, UITableViewDelegate {

    // MARK: - Constants

    private enum Constants {
        static let shadowRadius: CGFloat = 8
        static let shadowOpacity: Float = 0.2
        static let contentInset: CGFloat = UIDevice.isPad ? 10 : 5
        static let elementSpacing: CGFloat = UIDevice.isPad ? 15 : 10
        static let cancelButtonTitle: String = "Отмена"
        static let proposeButtonTitle: String = "Отправить"
        static let playerStackMultiplier: CGFloat = 0.1
        static let buttonsStackMultiplier: CGFloat = 0.08
        static let moneyInputHeight: CGFloat = UIDevice.isPad ? 20 : 15
        static let propertiesStackBottom: CGFloat = 10
        static let proposeButtonAlphaValid: CGFloat = 1.0
        static let proposeButtonAlphaInValid: CGFloat = 0.6
        static let differenceAllowedOffset: CGFloat = 0.5
        static let shadowOffsetHeight: CGFloat = 4
    }

    // MARK: - Private properties

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .init(width: .zero, height: Constants.shadowOffsetHeight)
        view.layer.shadowRadius = Constants.shadowRadius
        view.layer.shadowOpacity = Constants.shadowOpacity
        return view
    }()

    private let playersStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.contentInset
        return stack
    }()

    private let moneyInputStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.elementSpacing
        return stack
    }()

    private let propertiesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.elementSpacing
        return stack
    }()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Constants.elementSpacing
        return stack
    }()

    private let cancelButton = ActionButton(style: .negative, title: Constants.cancelButtonTitle)
    private let proposeButton = ActionButton(style: .positive, title: Constants.proposeButtonTitle)
    private let fromPropertiesTable = PropertiesTableView()
    private let toPropertiesTable = PropertiesTableView()
    private let fromMoneyInput = MoneyInputView()
    private let toMoneyInput = MoneyInputView()
    private let fromPlayerView = PlayerTradeView()
    private let toPlayerView = PlayerTradeView()
    private var fromPlayer: Player?
    private var toPlayer: Player?
    private var fromProperties: [Property] = []
    private var toProperties: [Property] = []

    // MARK: - Public properties

    weak var delegate: TradeViewDelegate?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupViews() {
        addSubview(containerView)
        containerView.addSubviews(playersStackView, moneyInputStack, propertiesStack, buttonsStack)

        playersStackView.addArrangedSubview(fromPlayerView)
        playersStackView.addArrangedSubview(toPlayerView)

        moneyInputStack.addArrangedSubview(fromMoneyInput)
        moneyInputStack.addArrangedSubview(toMoneyInput)

        propertiesStack.addArrangedSubview(fromPropertiesTable)
        propertiesStack.addArrangedSubview(toPropertiesTable)

        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(proposeButton)

        fromPropertiesTable.tableDelegate = self
        toPropertiesTable.tableDelegate = self
        fromMoneyInput.delegate = self
        toMoneyInput.delegate = self
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        playersStackView.translatesAutoresizingMaskIntoConstraints = false
        moneyInputStack.translatesAutoresizingMaskIntoConstraints = false
        propertiesStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playersStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.playerStackMultiplier),
            buttonsStack.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.buttonsStackMultiplier),

            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            playersStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.contentInset),
            playersStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentInset),
            playersStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentInset),

            moneyInputStack.topAnchor.constraint(equalTo: playersStackView.bottomAnchor, constant: Constants.elementSpacing),
            moneyInputStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentInset),
            moneyInputStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentInset),
            moneyInputStack.heightAnchor.constraint(equalToConstant: Constants.moneyInputHeight),

            buttonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentInset),
            buttonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentInset),
            buttonsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.contentInset),

            propertiesStack.topAnchor.constraint(equalTo: moneyInputStack.bottomAnchor, constant: Constants.elementSpacing),
            propertiesStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentInset),
            propertiesStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentInset),
            propertiesStack.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -Constants.propertiesStackBottom)
        ])
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        proposeButton.addTarget(self, action: #selector(didTapPropose), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapCancel() {
        delegate?.closeTradeView()
    }

    @objc private func didTapPropose() {
        guard let fromPlayer = fromPlayer, let toPlayer = toPlayer else { return }

        let model = TradeViewModel(
            fromPlayer: fromPlayer,
            toPlayer: toPlayer,
            fromPlayerProperties: fromProperties,
            toPlayerProperties: toProperties,
            fromPlayerMoney: fromMoneyInput.value,
            toPlayerMoney: toMoneyInput.value
        )

        delegate?.proposeTrade(model)
        clear()
    }

    // MARK: - Validation

    private func updateValidation() {
        let isValid = validateTrade()
        proposeButton.isEnabled = isValid
        proposeButton.alpha = isValid ? Constants.proposeButtonAlphaValid : Constants.proposeButtonAlphaInValid
    }

    private func validateTrade() -> Bool {
        guard let fromPlayer = fromPlayer, let toPlayer = toPlayer else { return false }

        let fromTotal = fromProperties.totalValue + fromMoneyInput.value
        let toTotal = toProperties.totalValue + toMoneyInput.value

        let fromCanAfford = fromMoneyInput.value <= fromPlayer.money
        let toCanAfford = toMoneyInput.value <= toPlayer.money

        let maxValue = max(fromTotal, toTotal)
        let minValue = min(fromTotal, toTotal)
        let differenceAllowed = Double(maxValue) * Constants.differenceAllowedOffset
        let isDifferenceValid = (Double(maxValue - minValue) <= differenceAllowed)

        return fromCanAfford && toCanAfford && isDifferenceValid && (!fromProperties.isEmpty || !toProperties.isEmpty)
    }

    // MARK: - Public Methods

    func configure(from: Player, to: Player) {
        self.fromPlayer = from
        self.toPlayer = to

        fromPlayerView.configure(
            name: from.name,
            balance: from.money,
            color: from.color
        )

        toPlayerView.configure(
            name: to.name,
            balance: to.money,
            color: to.color
        )
    }

    func addProperty(_ property: Property) {

        let isInFrom = fromProperties.contains(property)
        let isInTo = toProperties.contains(property)
        let isFromPlayerProperty = property.owner == fromPlayer?.id

        switch (isInFrom, isInTo) {
        case (true, _):
            if let index = fromProperties.firstIndex(of: property) {
                fromProperties.remove(at: index)
                fromPropertiesTable.remove(property)
            }
        case (_, true):
            if let index = toProperties.firstIndex(of: property) {
                toProperties.remove(at: index)
                toPropertiesTable.remove(property)
            }
        default:
            if isFromPlayerProperty {
                fromProperties.append(property)
                fromPropertiesTable.add(property)
            } else {
                toProperties.append(property)
                toPropertiesTable.add(property)
            }
        }

        updateValidation()
    }

    func clear() {
        fromProperties.removeAll()
        toProperties.removeAll()
        fromPropertiesTable.clear()
        toPropertiesTable.clear()
        fromMoneyInput.clear()
        toMoneyInput.clear()
    }
}

// MARK: - MoneyInputDelegate

extension TradeView: MoneyInputDelegate {

    func moneyValueChanged() {
        updateValidation()
    }
}

// MARK: - PropertiesTableDelegate

extension TradeView: PropertiesTableDelegate {

    func didRemoveProperty(_ property: Property) {
        if let index = fromProperties.firstIndex(of: property) {
            fromProperties.remove(at: index)
        } else if let index = toProperties.firstIndex(of: property) {
            toProperties.remove(at: index)
        }
        updateValidation()
    }
}
