//
//  ChanceManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 15.02.2025.
//

import UIKit

protocol ChanceManagerProtocol {
    /// Обработать карточку шанса
    /// - Parameters:
    ///   - player: игрок
    ///   - nextTurn: функция следующего хода
    ///   - moveCurrentPlayer: передвинуть фишку игрока
    ///   - rollDice: функция броска кубиков
    func handleChanceProperty(
        for player: Player,
        nextTurn: @escaping () -> Void?,
        moveCurrentPlayer: @escaping (Int) -> Void?,
        rollDice: @escaping () -> Void
    )
}

final class ChanceManager: ChanceManagerProtocol {

    // MARK: - Constants

    private enum Constants {
        static let goToStartDesc = "Перейдите на Старт - получите %@!"
        static let modalWinnerDesc = "Игрок победил(а) в конкурсе Душнила года. Получите %@!"
        static let sweetBunDesc = "Игрок получает %@. Просто потому что он(а) сладкая булочка ❤️!"
        static let luckyDesc = "Игрок нашел на дороге %@!"
        static let buildingsDesc = "Пора сделать ремонт собственности Игрок. Заплатите за каждую звезду - %@!"
        static let birthdayDesc = "У Игрок сегодня день рождения. Все скидываются ему на подарок по %@."
        static let netflixDesc = "Время глянуть пару серий. Отправляйтесь на Netflix."
        static let icecreamDesc = "Может по мороженному? Игрок отправляется в Buskin Robbins"
        static let coffeeDesc = "Ради кофе можно пойти на все. Даже на работу. Игрок отправляется в Starbucks"
        static let randomDesc = "Перейдите на рандомное поле."
        static let backMoveDesc = "Следующий ход будет в обратном направлении."
        static let fineDesc = "Игрок оштрафован за езду в нетрезвом виде на %@."
        static let jailDesc = "За просмотр пиратского контента Игрок отправляетесь в тюрьму."
        static let goldenAppleDesc = "Игрок выкупил(а) корзину в Золотом яблоке на %@."
        static let extraMoveDesc = "Дополнительный ход!"
        static let forwardAtThreeDesc = "Переместитесь вперед на %@ клетки!"
        static let parkDesc = "Игрок устал(а) и ушел в парк!"

        static let startPosition = 0
        static let netflixPosition = 32
        static let jailPosition = 10
        static let parkPosition = 20
        static let coffeePosition = 28
        static let icecreamPosition = 12

        static let goToStartAmount = 2000
        static let modalWinnerAmount = 1500
        static let sweetBunAmount = 500
        static let luckyAmount = 200
        static let buildingCostPerStar = 100
        static let birthdayContribution = 500
        static let fineAmount = 100
        static let goldenAppleAmount = 500

        static let forwardSteps = 3
        static let totalBoardCells = 40
        static let playerNamePlaceholder = "Игрок"
        static let alertTitle = "Карточка шанс"
        static let propertiesLogFormat = "Всего зданий у %@: %d. Игрок заплатил %d"
        static let randomMoveLogFormat = "%@ отправляется на %@"
        static let ok = "Ок"
    }

    // MARK: - Privvate properties

    private let databaseManager: FirebaseDatabaseManagerProtocol
    private let propertyManager: PropertyManagerProtocol
    private let playerManager: PlayerManagerProtocol
    private let alertManager: AlertManagerProtocol
    private let paymentManager: PaymentManagerProtocol
    private var cards: [ChanceCard]
    private var usedCards: [ChanceCard] = []

    // MARK: - Lifecycle

    init(
        databaseManager: FirebaseDatabaseManagerProtocol,
        propertyManager: PropertyManagerProtocol,
        playerManager: PlayerManagerProtocol,
        alertManager: AlertManagerProtocol,
        paymentManager: PaymentManagerProtocol
    ) {
        self.databaseManager = databaseManager
        self.propertyManager = propertyManager
        self.playerManager = playerManager
        self.alertManager = alertManager
        self.paymentManager = paymentManager

        self.cards = [
            ChanceCard(description: Constants.goToStartDesc, type: .goToStart),
            ChanceCard(description: Constants.modalWinnerDesc, type: .modalWinner),
            ChanceCard(description: Constants.sweetBunDesc, type: .sweetBun),
            ChanceCard(description: Constants.luckyDesc, type: .lucky),
            ChanceCard(description: Constants.buildingsDesc, type: .buildings),
            ChanceCard(description: Constants.birthdayDesc, type: .birthday),
            ChanceCard(description: Constants.netflixDesc, type: .netflix),
            ChanceCard(description: Constants.icecreamDesc, type: .icecream),
            ChanceCard(description: Constants.coffeeDesc, type: .coffee),
            ChanceCard(description: Constants.randomDesc, type: .random),
            ChanceCard(description: Constants.backMoveDesc, type: .backMove),
            ChanceCard(description: Constants.fineDesc, type: .fine),
            ChanceCard(description: Constants.jailDesc, type: .jail),
            ChanceCard(description: Constants.goldenAppleDesc, type: .goldenApple),
            ChanceCard(description: Constants.extraMoveDesc, type: .extraMove),
            ChanceCard(description: Constants.forwardAtThreeDesc, type: .forwardAtThree),
            ChanceCard(description: Constants.parkDesc, type: .park),
        ]
    }

    // MARK: - ChanceManagerProtocol

    func handleChanceProperty(
        for player: Player,
        nextTurn: @escaping () -> Void?,
        moveCurrentPlayer: @escaping (Int) -> Void?,
        rollDice: @escaping () -> Void
    ) {
        let chanceCard = drawCard(playerName: player.name)
        databaseManager.updateLog(message: chanceCard.description) { [weak self] result in
            self?.handleDatabaseResult(result)
        }

        showAlert(message: chanceCard.description) { [weak self] in
            self?.applyChanceEffect(player: player, chanceCard: chanceCard, nextTurn: nextTurn, moveCurrentPlayer: moveCurrentPlayer, rollDice: rollDice)
        }
    }

    // MARK: - Private methods

    private func applyChanceEffect(
        player: Player,
        chanceCard: ChanceCard,
        nextTurn: @escaping () -> Void?,
        moveCurrentPlayer: @escaping (Int) -> Void?,
        rollDice: @escaping () -> Void
    ) {
        switch chanceCard.type {
            case .coffee:
                let steps = (Constants.coffeePosition - player.position + Constants.totalBoardCells) % Constants.totalBoardCells
                moveCurrentPlayer(steps)
            case .icecream:
                let steps = (Constants.icecreamPosition - player.position + Constants.totalBoardCells) % Constants.totalBoardCells
                moveCurrentPlayer(steps)
            case .goToStart:
                databaseManager.updatePlayerMoney(playerID: player.id, money: player.money + Constants.goToStartAmount) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                databaseManager.updatePlayerPosition(playerID: player.id, position: Constants.startPosition) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                nextTurn()

            case .modalWinner:
                databaseManager.updatePlayerMoney(playerID: player.id, money: player.money + Constants.modalWinnerAmount) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                nextTurn()

            case .sweetBun:
                databaseManager.updatePlayerMoney(playerID: player.id, money: player.money + Constants.sweetBunAmount) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                nextTurn()

            case .lucky:
                databaseManager.updatePlayerMoney(playerID: player.id, money: player.money + Constants.luckyAmount) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                nextTurn()

            case .buildings:
                let properties = propertyManager.getProperties(for: player.id)
                let starCount = properties.reduce(.zero) { $0 + $1.buildings }
                if player.money >= Constants.buildingCostPerStar * starCount {
                    databaseManager.updatePlayerMoney(
                        playerID: player.id,
                        money: player.money - (Constants.buildingCostPerStar * starCount)
                    ) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }
                    databaseManager.updateLog(message: String(
                        format: Constants.propertiesLogFormat,
                        player.name,
                        starCount,
                        Constants.buildingCostPerStar * starCount
                    )) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }
                    nextTurn()
                } else {
                    if playerManager.getCurrentUserId() == player.id {
                        alertManager.showNoMoneyAlert(
                            amount: Constants.buildingCostPerStar * starCount,
                            payCompletion: {
                                self.paymentManager.payAfterNoMoney(player: player, amount: Constants.buildingCostPerStar * starCount, nextTurn: nextTurn)
                            },
                            nextTernAction: nextTurn
                        )
                    }
                }

            case .birthday:
                let otherPlayers = playerManager.getPlayers().filter { $0.id != player.id }
                for otherPlayer in otherPlayers {
                    if otherPlayer.money >= Constants.birthdayContribution {
                        databaseManager.updatePlayerMoney(playerID: otherPlayer.id, money: otherPlayer.money - Constants.birthdayContribution) { [weak self] result in
                            self?.handleDatabaseResult(result)
                        }
                    } else {
                        databaseManager.updatePlayerMoney(playerID: otherPlayer.id, money: .zero) { [weak self] result in
                            self?.handleDatabaseResult(result)
                        }
                    }
                }
                databaseManager.updatePlayerMoney(playerID: player.id, money: player.money + (Constants.birthdayContribution * otherPlayers.count)) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                nextTurn()

            case .netflix:
                let steps = (Constants.netflixPosition - player.position + Constants.totalBoardCells) % Constants.totalBoardCells
                moveCurrentPlayer(steps)
            case .random:
                let randomPosition = Int.random(in: .zero..<Constants.totalBoardCells)
                let property = propertyManager.getProperty(at: randomPosition)
                let steps = (randomPosition - player.position + Constants.totalBoardCells) % Constants.totalBoardCells
                databaseManager.updateLog(message: String(format: Constants.randomMoveLogFormat, player.name, property?.name ?? String.empty)) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                moveCurrentPlayer(steps)

            case .backMove:
                databaseManager.updatePlayerMoveToBack(playerID: player.id, isMoveBack: true) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                nextTurn()

            case .fine:
                if player.money >= Constants.fineAmount {
                    databaseManager.updatePlayerMoney(playerID: player.id, money: player.money - Constants.fineAmount) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }
                    nextTurn()
                } else {
                    if playerManager.getCurrentUserId() == player.id {
                        alertManager.showNoMoneyAlert(
                            amount: Constants.fineAmount,
                            payCompletion: {
                                self.paymentManager.payAfterNoMoney(player: player, amount: Constants.fineAmount, nextTurn: nextTurn)
                            },
                            nextTernAction: nextTurn
                        )
                    }
                }
            case .jail:
                databaseManager.updatePlayerInJail(player.id) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                databaseManager.updatePlayerPosition(playerID: player.id, position: Constants.jailPosition) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                nextTurn()

            case .goldenApple:
                if player.money >= Constants.goldenAppleAmount {
                    databaseManager.updatePlayerMoney(playerID: player.id, money: player.money - Constants.goldenAppleAmount) { [weak self] result in
                        self?.handleDatabaseResult(result)
                    }
                    nextTurn()
                } else {
                    if playerManager.getCurrentUserId() == player.id {
                        alertManager.showNoMoneyAlert(
                            amount: Constants.goldenAppleAmount,
                            payCompletion: {
                                self.paymentManager.payAfterNoMoney(player: player, amount: Constants.goldenAppleAmount, nextTurn: nextTurn)
                            },
                            nextTernAction: nextTurn
                        )
                    }
                }
            case .extraMove:
                if player.id == playerManager.getCurrentUserId() {
                    alertManager.yourMoveAlert(rollCompletion: rollDice)
                }

            case .forwardAtThree:
                moveCurrentPlayer(Constants.forwardSteps)

            case .park:
                databaseManager.updatePlayerPosition(playerID: player.id, position: Constants.parkPosition) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
                nextTurn()
        }
    }

    private func drawCard(playerName: String) -> ChanceCard {

        if cards.isEmpty {
            cards = usedCards
            usedCards.removeAll()
        }

        let index = Int.random(in: .zero..<cards.count)

        let card = cards[index]
        cards.remove(at: index)
        usedCards.append(card)

        let modifiedDescription = card.description
            .replacingOccurrences(of: Constants.playerNamePlaceholder, with: playerName)
            .replacingOccurrences(of: "%@", with: formattedAmount(for: card.type))

        let modifiedCard = ChanceCard(description: modifiedDescription, type: card.type)
        return modifiedCard
    }

    private func formattedAmount(for type: ChanceType) -> String {
        switch type {
            case .goToStart: return "\(Constants.goToStartAmount)k"
            case .modalWinner: return "\(Constants.modalWinnerAmount)k"
            case .sweetBun: return "\(Constants.sweetBunAmount)k"
            case .lucky: return "\(Constants.luckyAmount)k"
            case .buildings: return "\(Constants.buildingCostPerStar)k"
            case .birthday: return "\(Constants.birthdayContribution)k"
            case .fine: return "\(Constants.fineAmount)k"
            case .goldenApple: return "\(Constants.goldenAppleAmount)k"
            case .forwardAtThree: return "\(Constants.forwardSteps)"
        default: return String.empty
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

    private func showAlert(message: String, actionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: Constants.alertTitle,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: Constants.ok, style: .default) { _ in
            actionHandler?()
        }
        alert.addAction(okAction)
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.windows
            .first(where: \.isKeyWindow)

        guard let rootVC = window?.rootViewController,
              let topVC = rootVC.top else {
            return
        }

        topVC.present(alert, animated: true)
    }
}
