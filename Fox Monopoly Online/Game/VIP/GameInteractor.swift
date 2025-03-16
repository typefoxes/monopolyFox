//
//  GameInteractor.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.02.2025.
//

import UIKit

final class GameInteractorImpl {

    // MARK: - Constants

    private enum Constants {
        static let errorTitle = "Ошибка"
        static let insufficientFunds = "Недостаточно средств"
        static let propertyMortgaged = "закладывает"
        static let hotelSold = "продал отель на"
        static let hotelBuilt = "построил отель на"
        static let propertyRedeemed = "выкупает"
        static let currentPlayerTurn = "Ходит игрок:"
        static let hotelValue = 1
        static let lastPlayer: Int = 1
        static let playerColors: [UIColor] = [
            .redPlayer,
            .bluePlayer,
            .greenPlayer,
            .lavanderPlayer
        ]
    }

    // MARK: - Private properties

    private let presenter: GamePresenter
    private let playerManager: PlayerManagerProtocol
    private let propertyManager: PropertyManagerProtocol
    private let diceService: DiceServiceProtocol
    private let databaseManager: FirebaseDatabaseManagerProtocol
    private let auctionManager: AuctionManagerProtocol
    private let movementManager: MovementManagerProtocol
    private let alertManager: AlertManagerProtocol
    private let tradeManager: TradeManagerProtocol
    private let currentUserID: String

    // MARK: - Public properties

    weak var coordinator: GameScreenDelegate?

    // MARK: - Lifecycle

    init(
        presenter: GamePresenter,
        playerManager: PlayerManagerProtocol,
        propertyManager: PropertyManagerProtocol,
        diceService: DiceServiceProtocol,
        players: [PlayerData],
        currentUserID: String,
        databaseManager: FirebaseDatabaseManagerProtocol,
        auctionManager: AuctionManagerProtocol,
        movementManager: MovementManagerProtocol,
        alertManager: AlertManagerProtocol,
        tradeManager: TradeManagerProtocol
    ) {
        self.presenter = presenter
        self.playerManager = playerManager
        self.propertyManager = propertyManager
        self.diceService = diceService
        self.currentUserID = currentUserID
        self.databaseManager = databaseManager
        self.auctionManager = auctionManager
        self.movementManager = movementManager
        self.alertManager = alertManager
        self.tradeManager = tradeManager

        setupPlayers(players: players)
        setupObservers()
    }

    private func setupPlayers(players: [PlayerData]) {
        var allPlayers: [Player] = []
        var currentPlayerAssigned = false

        for (index, player) in players.enumerated() {
            let color = Constants.playerColors[index % Constants.playerColors.count]
            let isCurrent = !currentPlayerAssigned

            if isCurrent {
                currentPlayerAssigned = true
            }

            allPlayers.append(
                Player(
                    id: player.uid,
                    name: player.name,
                    color: color,
                    current: isCurrent
                )
            )
        }

        self.playerManager.setPlayers(players: allPlayers)
    }

    private func setupObservers() {
        /// Движения игроков на поле
        databaseManager.observePlayerMovements { [weak self] result in
            switch result {
                case .success(let (playerID, position)):
                    self?.handlePlayerMovements(playerID: playerID, position: position)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Игрок двигается в обратном направлении
        databaseManager.observePlayerMoveToBack { [weak self] result in
            switch result {
                case .success(let (playerID, isMoveBack)):
                    self?.playerManager.setNextMoveToBack(playerId: playerID, isMoveBack: isMoveBack)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Обновить владельца улицы
        databaseManager.observePropertyOwner { [weak self] result in
            switch result {
                case .success(let (propertyId, ownerId)):
                    self?.handlePropertyOwner(propertyId: propertyId, ownerId: ownerId)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Обновить деньги игроков
        databaseManager.observePlayerMoney { [weak self] result in
            switch result {
                case .success(let (playerID, money)):
                    self?.handlePlayerMoney(playerID: playerID, money: money)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Игрок в тюрьме
        databaseManager.observePlayerInJail { [weak self] result in
            switch result {
                case .success(let id):
                    self?.playerManager.sendPlayerToJail(id: id)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Обновить попытки в тюрьме
        databaseManager.observePlayerJailAttempts { [weak self] result in
            switch result {
                case .success(let id):
                    self?.playerManager.updateJailAttempts(id: id)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Игрок вышел из тюрьмы
        databaseManager.observePlayerReleasePlayerFromJail { [weak self] result in
            switch result {
                case .success(let id):
                    self?.playerManager.releasePlayerFromJail(id: id)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Текущий игрок сменился
        databaseManager.observeCurrentPlayer { [weak self] result in
            switch result {
                case .success(let currentPlayerID):
                    self?.handleCurrentPlayer(currentPlayerID: currentPlayerID)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Игрок сдался
        databaseManager.observeSurrenderPlayer { [weak self] result in
            switch result {
                case .success(let player):
                    self?.handleSurrenderPlayer(player: player)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Конец игры
        databaseManager.observeEndGame { [weak self] result in
            switch result {
                case .success:
                    self?.handleEndGame()
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Обновить лог игры
        databaseManager.observeLog { [weak self] result in
            switch result {
                case .success(let message):
                    self?.presenter.logOnBoard(message: message)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Аукцион
        databaseManager.observeAuction { [weak self] result in
            switch result {
                case .success(let auctionData):
                    self?.handleAuction(auctionData: auctionData)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Игрок выкупил улицу
        databaseManager.observePropertyRedeem { [weak self] result in
            switch result {
                case .success(let propertyId):
                    self?.handlePropertyRedeem(propertyId: propertyId)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Игрок заложил улицу
        databaseManager.observePropertyMortgage { [weak self] result in
            switch result {
                case .success(let propertyId):
                    self?.handlePropertyMortgage(propertyId: propertyId)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Игрок обновил отели
        databaseManager.observePropertyHotels { [weak self] result in
            switch result {
                case .success(let hotelsData):
                    self?.handlePropertyHotels(
                        propertyId: hotelsData.propertyId,
                        hotels: hotelsData.count
                    )
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }

        /// Игрок предложил сделку
        databaseManager.observeTradeProposal { [weak self] result in
            switch result {
                case .success(let proposalData):
                    self?.handleTradeProposal(proposalData: proposalData)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }
    }

    // MARK: - Observers handlers

    private func handlePlayerMoney(playerID: String, money: Int) {
        playerManager.updatePlayerMoney(playerId: playerID, money: money)
        presenter.updatePlayersInformation()
    }

    private func handlePropertyOwner(propertyId: Int, ownerId: String?) {
        if let color = playerManager.findPlayer(id: ownerId ?? String.empty)?.color {
            propertyManager.updatePropertyOwner(propertyId: propertyId, ownerId: ownerId, fieldColor: color)
            presenter.updateAllProperties()
        }
    }

    private func handlePlayerMovements(playerID: String, position: Int) {
        playerManager.updatePlayerPosition(playerId: playerID, position: position)
        presenter.movePlayerToPosition(position: position)
    }

    private func handleCurrentPlayer(currentPlayerID: String) {
        let index = playerManager.getPlayers().firstIndex { $0.id == currentPlayerID }
        playerManager.setCurrentPlayer(index: index ?? .zero)
        let current = playerManager.getCurrentPlayer()
        diceService.resetDoubles()
        presenter.logOnBoard(message: "\(Constants.currentPlayerTurn) \(current.name)")

        if current.inJail == true {
            presenter.updatePlayersInformation()
            if current.id == self.currentUserID {
                alertManager.askJailOptions(
                    payCompletion: { self.movementManager.payToGetOutOfJail() },
                    rollCompletion: { self.movementManager.rollDiceInJail() }
                )
            }
            return
        }

        presenter.updatePlayersInformation()

        if playerManager.getCurrentPlayer().id == currentUserID {
            alertManager.yourMoveAlert(rollCompletion: { self.movementManager.rollDice() } )
        }
    }

    private func handleSurrenderPlayer(player: String) {
        propertyManager.surrender(playerId: player)
        playerManager.surrender(playerId: player)
        presenter.playerSurrender(player)
        presenter.updatePlayersInformation()
        presenter.updateAllProperties()
        presenter.removeAlerts()

        let players =  playerManager.getPlayers().filter({ $0.isActive == true })
        guard let playerId = players.first?.id else { return }

        if players.count == Constants.lastPlayer {
            databaseManager.updateEndGame(playerId) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            return
        }

        movementManager.nextTurn()
    }

    private func handleEndGame() {
        guard let winner =  playerManager.getPlayers().filter({ $0.isActive == true }).first else { return }
        coordinator?.presentEndGameScreen(winner: winner)
    }

    private func handleAuction(auctionData: AuctionData) {
        auctionManager.nextAuctionTurn(
            auctionData: auctionData,
            nextTurn: { [weak self] in
                self?.movementManager.nextTurn()
            }
        )
    }

    private func handlePropertyRedeem(propertyId: Int) {
        guard let property = propertyManager.getProperty(at: propertyId) else { return }
        let currentPlayer = playerManager.getCurrentPlayer()
        propertyManager.redeemProperty(propertyId: propertyId)
        databaseManager.updateLog(message: "\(currentPlayer.name) \(Constants.propertyRedeemed) \(property.name)") { [weak self] result in
            self?.handleDatabaseResult(result)
        }

        presenter.updateAllProperties()
        presenter.updatePlayersInformation()
    }

    private func handlePropertyMortgage(propertyId: Int) {
        guard let property = propertyManager.getProperty(at: propertyId) else { return }
        let currentPlayer = playerManager.getCurrentPlayer()
        propertyManager.mortgageProperty(propertyId: propertyId)
        presenter.updatePlayersInformation()
        presenter.updateAllProperties()
        databaseManager.updateLog(message: "\(currentPlayer.name) \(Constants.propertyMortgaged) \(property.name)") { [weak self] result in
            self?.handleDatabaseResult(result)
        }
    }

    private func handlePropertyHotels(propertyId: Int, hotels: Int) {
        guard let property = propertyManager.getProperty(at: propertyId) else { return }
        let currentPlayer = playerManager.getCurrentPlayer()

        if hotels < .zero {
            propertyManager.updatePropertyBuildings(propertyId: property.position, buildings: hotels)
            databaseManager.updatePlayerMoney(playerID: currentPlayer.id, money: currentPlayer.money + property.buidPrice) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            databaseManager.updateLog(message: "\(currentPlayer.name) \(Constants.hotelSold) \(property.name)") { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            presenter.updateAllProperties()
            presenter.updatePlayersInformation()
        } else {
            if currentPlayer.money >= property.buidPrice {
                propertyManager.updatePropertyBuildings(propertyId: property.position, buildings: hotels)
                databaseManager.updatePlayerMoney(playerID: currentPlayer.id, money: currentPlayer.money - property.buidPrice) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                databaseManager.updateLog(message: "\(currentPlayer.name) \(Constants.hotelBuilt) \(property.name)") { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                presenter.updateAllProperties()
                presenter.updatePlayersInformation()
            } else {
                databaseManager.updateLog(message: Constants.insufficientFunds) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
            }
        }

        presenter.updatePlayersInformation()
        presenter.updateAllProperties()
    }

    private func handleTradeProposal(proposalData: TradeProposal) {
        guard
            let fromPlayer = playerManager.findPlayer(id: proposalData.fromPlayer),
            let toPlayer = playerManager.findPlayer(id: proposalData.toPlayer)
        else { return }

        var fromPlayerProperties: [Property] = []
        var toPlayerProperties: [Property] = []
        if let data = proposalData.fromPlayerProperties {
            for property in data {
                guard let findProperty = propertyManager.getProperty(at: property) else { return }
                fromPlayerProperties.append(findProperty)
            }
        }

        if let data = proposalData.toPlayerProperties {
            for property in data {
                guard let findProperty = propertyManager.getProperty(at: property) else { return }
                toPlayerProperties.append(findProperty)
            }
        }

        let trade = TradeViewModel(
            fromPlayer: fromPlayer,
            toPlayer: toPlayer,
            fromPlayerProperties: fromPlayerProperties,
            toPlayerProperties: toPlayerProperties,
            fromPlayerMoney: proposalData.fromPlayerMoney,
            toPlayerMoney: proposalData.toPlayerMoney
        )

        let model = TradeScreenModel(
            trade: trade,
            acceptAction: { [weak self] in
                self?.tradeManager.updateAfterTrade(trade)
            }
        )

        DispatchQueue.main.async { [weak self] in
            if toPlayer.id == self?.playerManager.getCurrentUserId() {
                self?.coordinator?.showTradeScreen(model)
            }
        }
    }

    // MARK: - UI taps

    private func handlePlayerSelection(index: Int, sourceView: UIView) {
        do {
            let player = try playerManager.getPlayer(index: index)
            let activePlayer = playerManager.getCurrentPlayer()

            let model = PlayerMenuViewModel(
                player: player,
                sourceView: sourceView,
                activePlayer: activePlayer,
                surrenderAction: { [weak self] in
                    self?.databaseManager.updatePlayerSurrender(playerId: player.id) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }
                },
                tradeAction: { [weak self] in
                    self?.presenter.showTradingView(
                        currentPlayer: activePlayer,
                        tradingPlayer: player
                    )
                }
            )

            if activePlayer.id == playerManager.getCurrentUserId() {
                DispatchQueue.main.async { [weak self] in
                    self?.coordinator?.showPlayerMenu(model)
                }
            }
        } catch {
            coordinator?.showAlert(
                title: Constants.errorTitle,
                message: GameError.invalidPlayerIndex.localizedDescription
            )
        }
    }

    private func handlePropertySelection(property: Property, sourceView: UIView) {
        let activePlayer = playerManager.getCurrentPlayer()
        let canBuild = propertyManager.canBuild(on: property) && activePlayer.money >= property.buidPrice

        let model = PropertyMenuViewModel(
            property: property,
            sourceView: sourceView,
            activePlayer: activePlayer,

            buildAction: canBuild ? { [weak self] in
                self?.propertyManager.writeBuild(property)
                self?.databaseManager.updatePropertyHotels(propertyId: property.position, hotels: +Constants.hotelValue) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
            } : nil,

            sellAction: propertyManager.canSellBuild(on: property) ? { [weak self] in
                self?.databaseManager.updatePropertyHotels(propertyId: property.position, hotels: -Constants.hotelValue) { [weak self] result in
                    self?.handleDatabaseResult(result)
                    self?.presenter.updatePayButtonInAlert(amount: activePlayer.amountDebt)
                }
            } : nil,

            mortgageAction: (property.active && property.buildings == .zero && propertyManager.canMortgage(property)) ? { [weak self] in
                self?.databaseManager.updatePlayerMoney(playerID: activePlayer.id, money: activePlayer.money + property.lockMoney) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                self?.databaseManager.updatePropertyMortgage(propertyId: property.position) { [weak self] result in
                    self?.handleDatabaseResult(result)
                    self?.presenter.updatePayButtonInAlert(amount: activePlayer.amountDebt)
                }
            } : nil,

            redeemAction: !property.active && activePlayer.money >= property.rebuyMoney ? { [weak self] in
                self?.databaseManager.updatePlayerMoney(playerID: activePlayer.id, money: activePlayer.money - property.rebuyMoney) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                self?.databaseManager.updatePropertyRedeem(propertyId: property.position) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
            } : nil
        )

        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.showPropertyMenu(model)
        }
    }

    private func handleStartGame() {
        presenter.startGame()
        if playerManager.getCurrentPlayer().id == currentUserID {
            alertManager.yourMoveAlert { [weak self] in
                self?.movementManager.rollDice()
            }
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

// MARK: - GameInteractor

extension GameInteractorImpl: GameInteractor {

    func handleRequest(_ request: GameModel.Request) {
        switch request {
            case .animateMovement(let stepsRemaining):
                movementManager.animateMovement(stepsRemaining: stepsRemaining)
            case .rollDice:
                movementManager.rollDice()
            case .startGame:
                handleStartGame()
            case .didSelectPlayer(let index, let sourceView):
                handlePlayerSelection(index: index, sourceView: sourceView)
            case .didSelectProperty(let property, let sourceView):
                handlePropertySelection(property: property, sourceView: sourceView)
            case .proposeTrade(let model):
                databaseManager.proposeTrade(model: model) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
            case .exitGame:
                coordinator?.exitGame()
        }
    }
}
