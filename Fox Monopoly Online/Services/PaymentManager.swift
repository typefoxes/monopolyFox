//
//  PaymentManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 01.03.2025.
//

protocol PaymentManagerProtocol {
    /// Обрабатывает оплату аренды за поле
    /// - Parameters:
    ///   - property: Объект, за который взимается аренда
    ///   - player: Игрок, производящий оплату
    ///   - nextTurn: Замыкание для перехода к следующему ходу
    func handleRentPayment(
        _ property: Property,
        for player: Player,
        nextTurn: @escaping () -> Void?
    )
    /// Обрабатывает ситуацию недостатка средств у игрока
    /// - Parameters:
    ///   - player: Игрок с недостатком средств
    ///   - amount: Необходимая сумма для выполнения операции
    ///   - reason: Причина возникновения долга (аренда, налоги и т.д.)
    ///   - nextTurn: Замыкание для перехода к следующему ходу
    func handleInsufficientFunds(
        for player: Player,
        amount: Int,
        reason: String,
        nextTurn: @escaping () -> Void?
    )
    /// Завершает процесс оплаты после устранения недостатка средств
    /// - Parameters:
    ///   - player: Игрок, завершающий оплату
    ///   - amount: Сумма к оплате
    ///   - nextTurn: Замыкание для перехода к следующему ходу
    func payAfterNoMoney(
        player: Player,
        amount: Int,
        nextTurn: @escaping () -> Void?
    )
    /// Обрабатывает покупку объекта
    /// - Parameters:
    ///   - property: Объект недвижимости для покупки
    ///   - player: Игрок-покупатель (nil - текущий игрок)
    ///   - price: Цена покупки (nil - базовая цена свойства)
    ///   - nextTurn: Замыкание для перехода к следующему ходу
    func buyProperty(
        property: Property,
        _ player: Player?,
        _ price: Int?,
        nextTurn: @escaping () -> Void?
    )
}

final class PaymentManager: PaymentManagerProtocol {

    // MARK: - Constants

    private struct Constants {
        static let rentPaid = "💰 %@ заплатил %dk ренты за %@!"
        static let insufficientFunds = "🚫 У %@ недостаточно средств для %@ (%dk)."
        static let propertyBought = "🎉 %@ купил %@ за %dk!"
        static let purchaseFailed = "🚫 У %@ недостаточно денег для покупки %@!"
        static let bailAmount = 500
        static let payRent = "оплаты ренты"
    }

    // MARK: - Properties

    private let diceService: DiceServiceProtocol
    private let propertyManager: PropertyManagerProtocol
    private let databaseManager: FirebaseDatabaseManagerProtocol
    private let playerManager: PlayerManagerProtocol
    private let alertManager: AlertManagerProtocol

    // MARK: - Lifecycle

    init(
        diceService: DiceServiceProtocol,
        propertyManager: PropertyManagerProtocol,
        databaseManager: FirebaseDatabaseManagerProtocol,
        playerManager: PlayerManagerProtocol,
        alertManager: AlertManagerProtocol
    ) {
        self.diceService = diceService
        self.propertyManager = propertyManager
        self.databaseManager = databaseManager
        self.playerManager = playerManager
        self.alertManager = alertManager
    }

    // MARK: - PaymentManagerProtocol

    func handleRentPayment(_ property: Property, for player: Player, nextTurn: @escaping () -> Void?) {
        guard let owner = property.owner else { return }
        let rent = property.rent(
            diceRoll: diceService.getCurrentDices(),
            properties: propertyManager.getProperties(for: owner)
)
        if player.money >= rent {
            databaseManager.updatePlayerMoney(playerID: player.id, money: player.money - rent) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            if let ownerMoney = playerManager.findPlayer(id: owner)?.money {
                databaseManager.updatePlayerMoney(playerID: owner, money: ownerMoney + rent) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
            }

            databaseManager.updateLog(
                message: String(
                    format: Constants.rentPaid,
                    player.name,
                    rent,
                    property.name
                )
            ) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            nextTurn()
        } else {
            handleInsufficientFunds(for: player, amount: rent, reason: Constants.payRent, nextTurn: nextTurn)
        }
    }

    func handleInsufficientFunds(for player: Player, amount: Int, reason: String, nextTurn: @escaping () -> Void?) {
        databaseManager.updateLog(
            message: String(
                format: Constants.insufficientFunds,
                player.name,
                reason,
                amount
            )
        ) { [weak self] result in
            self?.handleDatabaseResult(result)
        }

        if playerManager.getCurrentPlayer().id == playerManager.getCurrentUserId() {
            alertManager.showNoMoneyAlert(
                amount: amount,
                payCompletion: { self.payAfterNoMoney(player: player, amount: amount, nextTurn: nextTurn) },
                nextTernAction: nextTurn
            )
        }
    }

    func payAfterNoMoney(player: Player, amount: Int, nextTurn: @escaping () -> Void?) {
        databaseManager.updatePlayerMoney(playerID: player.id, money: player.money - amount) { [weak self] result in
            self?.handleDatabaseResult(result)
        }

        nextTurn()
    }

    func buyProperty(property: Property, _ player: Player? = nil, _ price: Int? = nil, nextTurn: @escaping () -> Void?) {
        let currentPlayer = player ?? playerManager.getCurrentPlayer()
        let price = price ?? property.price

        if currentPlayer.money >= price {
            databaseManager.updatePlayerMoney(playerID: currentPlayer.id, money: currentPlayer.money - price) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            databaseManager.updatePropertyOwner(propertyId: property.position, ownerId: currentPlayer.id) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            databaseManager.updateLog(
                message: String(
                    format: Constants.propertyBought,
                    currentPlayer.name,
                    property.name,
                    price
                )
            ) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            nextTurn()
        } else {
            databaseManager.updateLog(
                message: String(
                    format: Constants.purchaseFailed,
                    currentPlayer.name,
                    property.name
                )
            ) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            nextTurn()
        }
    }

    // MARK: - Private methods

    private func handleDatabaseResult<T>(_ result: Result<T, FirebaseDatabaseManagerError>) {
        switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
            case .success:
                break
        }
    }
}
