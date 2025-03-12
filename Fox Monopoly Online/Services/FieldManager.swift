//
//  FieldManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 01.03.2025.
//

import os

protocol FieldManagerProtocol {
    /// Обрабатывает взаимодействие со стартовым полем
    /// - Parameter steps: Количество шагов, которые игрок прошёл за ход
    func handleStartProperty(steps: Int)
    /// Обрабатывает взаимодействие с игровым полем-собственностью
    /// - Parameters:
    ///   - property: Объект игрового поля
    ///   - nextTurn: Замыкание для перехода к следующему ходу
    ///   - moveCurrentPlayer: Замыкание для перемещения игрока (принимает количество шагов)
    ///   - rollDice: Замыкание для повторного броска кубиков (для специальных случаев)
    func handleProperty(
        property: Property,
        nextTurn: @escaping () -> Void,
        moveCurrentPlayer: @escaping (Int) -> Void?,
        rollDice: @escaping () -> Void
    )
}

final class FieldManager: FieldManagerProtocol {

    // MARK: - Constants

    private struct Constants {
        static let passedStart = "💰 %@ прошёл Старт и получает бонус %dk!"
        static let landedOnStart = "💰 %@ остановился на поле СТАРТ и получает бонус %dk!"
        static let arrested = "🚨 %@ арестован(а) за читерство."
        static let taxPaid = "%@ заплатил налогов на сумму: %dk"
        static let propertyAvailable = "🏡 Улица доступна для покупки: %@ за %dk"
        static let totalCells = 40
        static let jailPosition = 10
        static let passStart = 2000
        static let landOnStart = 1000
        static let reason = "уплаты налогов"
    }

    // MARK: - Properties

    private let playerManager: PlayerManagerProtocol
    private let databaseManager: FirebaseDatabaseManagerProtocol
    private let paymentManager: PaymentManagerProtocol
    private let alertManager: AlertManagerProtocol
    private let auctionManager: AuctionManagerProtocol
    private let chanceManager: ChanceManagerProtocol

    // MARK: - Lifecycle

    init(
        playerManager: PlayerManagerProtocol,
        databaseManager: FirebaseDatabaseManagerProtocol,
        paymentManager: PaymentManagerProtocol,
        alertManager: AlertManagerProtocol,
        auctionManager: AuctionManagerProtocol,
        chanceManager: ChanceManagerProtocol
    ) {
        self.playerManager = playerManager
        self.databaseManager = databaseManager
        self.paymentManager = paymentManager
        self.alertManager = alertManager
        self.auctionManager = auctionManager
        self.chanceManager = chanceManager
    }

    // MARK: - FieldManagerProtocol

    func handleStartProperty(steps: Int) {
        let currentPlayer = playerManager.getCurrentPlayer()
        let totalCells = Constants.totalCells

        if currentPlayer.isMoveBack {
            if currentPlayer.position - steps <= .zero && currentPlayer.position != 0 {
                updatePlayerBonus(
                    player: currentPlayer,
                    amount: Constants.passStart,
                    message: Constants.passedStart
                )
            }
            if currentPlayer.position - steps == .zero {
                updatePlayerBonus(
                    player: currentPlayer,
                    amount: Constants.landOnStart,
                    message: Constants.landedOnStart
                )
            }
        } else {
            if currentPlayer.position + steps >= totalCells {
                updatePlayerBonus(
                    player: currentPlayer,
                    amount: Constants.passStart,
                    message: Constants.passedStart
                )
            }

            if currentPlayer.position + steps == totalCells {
                updatePlayerBonus(
                    player: currentPlayer,
                    amount: Constants.landOnStart,
                    message: Constants.landedOnStart
                )
            }
        }
    }

    func handleProperty(
        property: Property,
        nextTurn: @escaping () -> Void,
        moveCurrentPlayer: @escaping (Int) -> Void?,
        rollDice: @escaping () -> Void
    ) {
        let currentPlayer = playerManager.getCurrentPlayer()

        switch property.cardType {
        case .cop:
            handleCopProperty(for: currentPlayer, nextTurn: nextTurn)
        case .tax:
            handleTaxProperty(property, for: currentPlayer, nextTurn: nextTurn)
        case .chance:
            chanceManager.handleChanceProperty(
                for: currentPlayer,
                nextTurn: nextTurn,
                moveCurrentPlayer: moveCurrentPlayer,
                rollDice: rollDice
            )
        case .streets:
            handlePurchasableProperty(property, for: currentPlayer, nextTurn: nextTurn)
        case .start, .jail, .park:
            nextTurn()
        }
    }

    // MARK: - Private methods

    private func updatePlayerBonus(player: Player, amount: Int, message: String) {
        databaseManager.updatePlayerMoney(playerID: player.id, money: player.money + amount) { [weak self] result in
            self?.handleDatabaseResult(result)
        }
        databaseManager.updateLog(
            message: String(format: message, player.name, amount)
        ) { [weak self] result in
            self?.handleDatabaseResult(result)
        }
    }

    private func handleCopProperty(for player: Player, nextTurn: @escaping () -> Void) {
        databaseManager.updateLog(
            message: String(format: Constants.arrested, player.name)
        ) { [weak self] result in
            self?.handleDatabaseResult(result)
        }
        databaseManager.updatePlayerInJail(player.id) { [weak self] result in
            self?.handleDatabaseResult(result)
        }
        databaseManager.updatePlayerPosition(
            playerID: player.id,
            position: Constants.jailPosition
        ) { [weak self] result in
            self?.handleDatabaseResult(result)
        }
        nextTurn()
    }

    private func handleTaxProperty(_ property: Property, for player: Player, nextTurn: @escaping () -> Void) {
        let taxAmount = property.type.data.baseRent

        if player.money >= taxAmount {
            databaseManager.updatePlayerMoney(playerID: player.id, money: player.money - taxAmount) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            databaseManager.updateLog(
                message: String(format: Constants.taxPaid, player.name, taxAmount)
            ) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            nextTurn()
        } else {
            paymentManager.handleInsufficientFunds(
                for: player,
                amount: taxAmount,
                reason: Constants.reason,
                nextTurn: nextTurn
            )
        }
    }

    private func handlePurchasableProperty(_ property: Property, for player: Player, nextTurn: @escaping () -> Void) {
        if property.owner == nil {
            handleUnownedProperty(property, for: player, nextTurn: nextTurn)
        } else if property.owner == player.id {
            nextTurn()
        } else {
            paymentManager.handleRentPayment(property, for: player, nextTurn: nextTurn)
        }
    }

    private func handleUnownedProperty(_ property: Property, for player: Player, nextTurn: @escaping () -> Void) {
        databaseManager.updateLog(
            message: String(format: Constants.propertyAvailable, property.name, property.price)
        ) { [weak self] result in
            self?.handleDatabaseResult(result)
        }

        if player.money >= property.price {

            if playerManager.getCurrentPlayer().id == playerManager.getCurrentUserId() {
                alertManager.showBuyingAlert(
                    property: property,
                    buyCompletion: { self.paymentManager.buyProperty(property: property, nil, nil, nextTurn: nextTurn) },
                    auctionCompletion: { self.auctionManager.startAuction(for: property, nextTurn: nextTurn) }
                )
            }
        } else {
            auctionManager.startAuction(for: property, nextTurn: nextTurn)
        }
    }

    private func handleDatabaseResult<T>(_ result: Result<T, FirebaseDatabaseManagerError>) {
        switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
            case .success:
                break
        }
    }
}
