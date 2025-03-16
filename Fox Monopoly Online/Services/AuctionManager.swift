//
//  AuctionManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 01.03.2025.
//

protocol AuctionManagerProtocol {
    /// Начать аукцион
    /// - Parameters:
    ///   - property: поле на аукцион
    ///   - nextTurn: функция следующего хода
    func startAuction(for property: Property, nextTurn: @escaping () -> Void?)
    /// Круг аукциона
    /// - Parameters:
    ///   - auctionData: модель аукциона
    ///   - nextTurn: функция следующего хода
    func nextAuctionTurn(auctionData: AuctionData, nextTurn: @escaping () -> Void?)
}

final class AuctionManager: AuctionManagerProtocol {

    // MARK: - Constants

    private struct Constants {
        static let noBuyerLogMessage = "🏡 Никто не купил %@ на аукционе."
        static let dropOutLogMessage = "%@ выбывает из аукциона! Недостаточно средств."
        static let raiseBidLogMessage = "%@ поднял ставку до %dk!"
        static let refuseLogMessage = "%@ отказался от участия в аукционе!"
        static let winnerLogMessage = "🎉 %@ выиграл аукцион и купил %@ за %dk!"
        static let buyButtonTitle = "Купить"
        static let bidIncrement = 100
        static let onePlayer = 1
    }

    // MARK: - Private properties

    private let playerManager: PlayerManagerProtocol
    private let propertyManager: PropertyManagerProtocol
    private let databaseManager: FirebaseDatabaseManagerProtocol
    private let paymentManager: PaymentManagerProtocol
    private let alertManager: AlertManagerProtocol

    // MARK: - Lifecycle

    init(
        playerManager: PlayerManagerProtocol,
        databaseManager: FirebaseDatabaseManagerProtocol,
        paymentManager: PaymentManagerProtocol,
        alertManager: AlertManagerProtocol,
        propertyManager: PropertyManagerProtocol
    ) {
        self.playerManager = playerManager
        self.databaseManager = databaseManager
        self.paymentManager = paymentManager
        self.alertManager = alertManager
        self.propertyManager = propertyManager
    }

    // MARK: - AuctionManagerProtocol

    func startAuction(for property: Property, nextTurn: @escaping () -> Void?) {
        let allPlayers = playerManager.getPlayers()
        let currentPlayer = playerManager.getCurrentPlayer()
        let currentBidderIndex: Int? = nil

        let auctionPlayers = allPlayers.filter { $0.money >= property.price && $0.id != currentPlayer.id && $0.isActive }.map { $0.id }

        if !auctionPlayers.isEmpty {
            let auctionData = AuctionData(
                propertyPosition: property.position,
                propertyPrice: property.price,
                currentBid: property.price,
                auctionPlayers: auctionPlayers,
                currentBidderIndex: currentBidderIndex

            )

            databaseManager.updateAuction(auctionData) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
        } else {
            nextTurn()
        }
    }

    func nextAuctionTurn(auctionData: AuctionData, nextTurn: @escaping () -> Void?) {

        guard let property = propertyManager.getProperty(at: auctionData.propertyPosition) else { return }

        let currentPlayer = playerManager.getCurrentPlayer()
        let allPlayers = playerManager.getPlayers()

        var temp: [Player] = []
        for player in auctionData.auctionPlayers {
            if let play = playerManager.findPlayer(id: player) {
                temp.append(play)
            }
        }

        var auctionPlayers = temp.enumerated()
            .filter { $0.element.money >= property.price && $0.element.id != currentPlayer.id }
            .map { $0 }
        guard !auctionData.auctionPlayers.isEmpty else {

            if let winnerIndex = auctionData.currentBidderIndex, allPlayers[winnerIndex].money >= auctionData.currentBid {
                if let property = propertyManager.getProperty(at: auctionData.propertyPosition) {
                    paymentManager.buyProperty(property: property, allPlayers[winnerIndex], auctionData.currentBid, nextTurn: nextTurn)
                }
            } else {
                if let property = propertyManager.getProperty(at: auctionData.propertyPosition) {
                    databaseManager.updateLog(message: String(format: Constants.noBuyerLogMessage, property.name)) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }
                }
                nextTurn()
            }
            return
        }

        if auctionData.auctionPlayers.count == Constants.onePlayer {
            let lastPlayer = auctionPlayers.first!

            if lastPlayer.offset == auctionData.currentBidderIndex {
                paymentManager.buyProperty(property: property, lastPlayer.element, auctionData.currentBid, nextTurn: nextTurn)
            } else if lastPlayer.element.money >= auctionData.currentBid {

                if lastPlayer.element.id == playerManager.getCurrentUserId() {
                    alertManager.showTurnAuctionAlert(
                        property: property,
                        player: lastPlayer.element,
                        currentBid: auctionData.currentBid,
                        buyTitle: Constants.buyButtonTitle,
                        completionOk: {
                            self.paymentManager.buyProperty(property: property, lastPlayer.element, auctionData.currentBid, nextTurn: nextTurn)
                        },
                        completion: {
                            self.databaseManager.updateLog(message: String(format: Constants.noBuyerLogMessage, property.name)) { [weak self] result in
                                self?.handleDatabaseResult(result)
                            }
                            nextTurn()
                        }
                    )
                }
            } else {
                databaseManager.updateLog(message: String(format: Constants.noBuyerLogMessage, property.name)) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                nextTurn()
            }
            return
        }

        let (index, player) = auctionPlayers.removeFirst()

        if player.money < auctionData.currentBid + Constants.bidIncrement {
            auctionPlayers.remove(at: index)
            let auctionDataUpdate = AuctionData(
                propertyPosition: property.position,
                propertyPrice: property.price,
                currentBid: auctionData.currentBid,
                auctionPlayers: auctionPlayers.map {
                    $0.element.id
                })
            self.databaseManager.updateLog(message: String(format: Constants.dropOutLogMessage, player.name)) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            databaseManager.updateAuction(auctionDataUpdate) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            return
        }

        if player.id == playerManager.getCurrentUserId() {
            alertManager.showTurnAuctionAlert(
                property: property,
                player: player,
                currentBid: auctionData.currentBid,
                buyTitle: nil,
                completionOk: {
                    auctionPlayers.append((index, player))
                    let auctionDataUpdated = AuctionData(
                        propertyPosition: property.position,
                        propertyPrice: property.price,
                        currentBid: auctionData.currentBid + Constants.bidIncrement,
                        auctionPlayers: auctionPlayers.map {
                            $0.element.id
                        },
                        currentBidderIndex: index)
                    self.databaseManager.updateLog(message: String(
                        format: Constants.raiseBidLogMessage,
                        player.name,
                        auctionData.currentBid + Constants.bidIncrement
                    )) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }

                    self.databaseManager.updateAuction(auctionDataUpdated) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }
                },
                completion: {
                    let auctionDataUpdate = AuctionData(
                        propertyPosition: property.position,
                        propertyPrice: property.price,
                        currentBid: auctionData.currentBid,
                        auctionPlayers: auctionPlayers.map {
                            $0.element.id
                        })

                    self.databaseManager.updateLog(message: String(format: Constants.refuseLogMessage, player.name)) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }

                    self.databaseManager.updateAuction(auctionDataUpdate) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }
                }
            )
        }
    }

    private func finalizeAuction(winner: Player, property: Property, bid: Int, nextTurn: @escaping () -> Void?) {
        databaseManager.updatePlayerMoney(playerID: winner.id, money: winner.money - bid) { [weak self] result in
            self?.handleDatabaseResult(result)
        }

        databaseManager.updatePropertyOwner(propertyId: property.position, ownerId: winner.id) { [weak self] result in
            self?.handleDatabaseResult(result)
        }

        databaseManager.updateLog(message: String(format: Constants.winnerLogMessage, winner.name, property.name, bid)) { [weak self] result in
            self?.handleDatabaseResult(result)
        }

        nextTurn()
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
