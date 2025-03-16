//
//  MovementManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 01.03.2025.
//

protocol MovementManagerProtocol {
    /// Выполняет бросок кубиков и инициирует перемещение игрока
    /// - Note: Генерирует случайные значения кубиков, обновляет UI и запускает движение
    func rollDice()
    /// Перемещает текущего игрока на указанное количество шагов
    /// - Parameter steps: Количество шагов для перемещения
    func moveCurrentPlayer(steps: Int)
    /// Анимирует пошаговое перемещение игрока
    /// - Parameter stepsRemaining: Оставшееся количество шагов для анимации
    func animateMovement(stepsRemaining: Int)
    /// Передает ход следующему игроку
    func nextTurn()
    /// Оплата выхода из тюрьмы
    func payToGetOutOfJail()
    /// Бросок кубиков в тюрьме
    func rollDiceInJail()
    /// Ссылка на игровое представление для обновления UI
    var delegate: GameView? { get set }
}

final class MovementManager: MovementManagerProtocol {

    // MARK: - Constants

    private struct Constants {
        static let diceRoll = "🎲 Бросок: %d + %d = %d"
        static let threeDoubles = "🚨 Три дубля подряд! Игрок отправляется в тюрьму."
        static let doublesTurn = "🎲 Дубль! %@ снова ходит."
        static let jailReleaseSuccess = "%@ бросил дубль и выходит из тюрьмы."
        static let jailReleaseFail = "%@ не смог(ла) бросит дубль и остается в тюрьме."
        static let paidBail = "💸 %@ заплатил %dk и вышел из тюрьмы."
        static let insufficientBail = "🚫 У %@ недостаточно средств, чтобы заплатить %dk!"
        static let jail = 10
        static let totalCells = 40
        static let lastCellIndex = 39
        static let bailAmount = 500
        static let maxAttempts = 2
        static let one = 1
    }

    // MARK: - Properties

    private let diceService: DiceServiceProtocol
    private let databaseManager: FirebaseDatabaseManagerProtocol
    private let playerManager: PlayerManagerProtocol
    private let fieldManager: FieldManagerProtocol
    private let propertyManager: PropertyManagerProtocol
    private let alertManager: AlertManagerProtocol

    weak var delegate: GameView?

    // MARK: - Lifecycle

    init(
        diceService: DiceServiceProtocol,
        databaseManager: FirebaseDatabaseManagerProtocol,
        playerManager: PlayerManagerProtocol,
        fieldManager: FieldManagerProtocol,
        propertyManager: PropertyManagerProtocol,
        alertManager: AlertManagerProtocol
    ) {
        self.diceService = diceService
        self.databaseManager = databaseManager
        self.playerManager = playerManager
        self.fieldManager = fieldManager
        self.propertyManager = propertyManager
        self.alertManager = alertManager
    }

    // MARK: - MovementManagerProtocol

    func rollDice() {
        let result = diceService.rollDice()
        let totalSteps = result.dice1 + result.dice2
        let currentPlayer = playerManager.getCurrentPlayer()

        databaseManager.updateLog(
            message: String(
                format: Constants.diceRoll,
                result.dice1,
                result.dice2,
                totalSteps
            )
        ) { [weak self] result in
            self?.handleDatabaseResult(result)
        }

        if diceService.hasThreeDoubles() {
            databaseManager.updateLog(message: Constants.threeDoubles) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            databaseManager.updatePlayerInJail(currentPlayer.id) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            databaseManager.updatePlayerPosition(playerID: currentPlayer.id, position: Constants.jail) { [weak self] result in
                self?.handleDatabaseResult(result)
            }

            diceService.resetDoubles()
            nextTurn()
            return
        }

        moveCurrentPlayer(steps: totalSteps)
    }

    func moveCurrentPlayer(steps: Int) {
        fieldManager.handleStartProperty(steps: steps)
        animateMovement(stepsRemaining: steps)
    }

    func animateMovement(stepsRemaining: Int) {
        let currentPlayer = playerManager.getCurrentPlayer()
        guard stepsRemaining > .zero else {
            guard let property = propertyManager.getProperty(at: currentPlayer.position) else { return }
            databaseManager.updatePlayerMoveToBack(playerID: currentPlayer.id, isMoveBack: false) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            databaseManager.updatePlayerPosition(playerID: currentPlayer.id, position: currentPlayer.position) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            fieldManager.handleProperty(
                property: property,
                nextTurn: { self.nextTurn() },
                moveCurrentPlayer: { steps in self.moveCurrentPlayer(steps: steps) },
                rollDice: { self.rollDice() })
            return
        }

        let newPosition: Int
        if currentPlayer.isMoveBack {
            newPosition = currentPlayer.position == .zero ? Constants.lastCellIndex : (currentPlayer.position - Constants.one) % Constants.totalCells
        } else {
            newPosition = (currentPlayer.position + Constants.one) % Constants.totalCells
        }

        let isLastStep = stepsRemaining == Constants.one
        playerManager.updatePlayerPosition(playerId: currentPlayer.id, position: newPosition)
        databaseManager.updatePlayerPosition(playerID: currentPlayer.id, position: newPosition) { [weak self] result in
            self?.handleDatabaseResult(result)
        }
        delegate?.moveOneStep(stepsRemaining: stepsRemaining - Constants.one, position: playerManager.getCurrentPlayer().position, isLastStep: isLastStep)
    }

    func nextTurn() {
        propertyManager.resetBuiltThisTurn()
        if diceService.getDoubles() <= .zero {
            playerManager.nextPlayer()
            let nextPlayerId = playerManager.getCurrentPlayer().id
            databaseManager.updateCurrentPlayer(nextPlayerId: nextPlayerId) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
        } else {
            databaseManager.updateLog(message: String(format: Constants.doublesTurn, playerManager.getCurrentPlayer().name)) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            if playerManager.getCurrentPlayer().id == playerManager.getCurrentUserId() {
                alertManager.yourMoveAlert(rollCompletion: rollDice)
            }
        }
    }

    func rollDiceInJail() {
        let player = playerManager.getCurrentPlayer()
        databaseManager.updatePlayerJailAttempts(player.id) { [weak self] result in
            self?.handleDatabaseResult(result)
        }
        let result = diceService.rollDice()

        if result.isDouble {
            databaseManager.updatePlayerReleasePlayerFromJail(player.id) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            moveCurrentPlayer(steps: result.dice1 + result.dice2)
            databaseManager.updateLog(message: String(format: Constants.jailReleaseSuccess, player.name)) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            return
        } else {
            diceService.resetDoubles()
            if player.jailAttempts == Constants.maxAttempts {
                payToGetOutOfJail()
                return
            }
            databaseManager.updateLog(message: String(format: Constants.jailReleaseFail, player.name)) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            nextTurn()
        }
    }

    func payToGetOutOfJail() {
        let currentPlayer = playerManager.getCurrentPlayer()
        if currentPlayer.money >= Constants.bailAmount {
            databaseManager.updatePlayerReleasePlayerFromJail(currentPlayer.id) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            databaseManager.updatePlayerMoney(playerID: currentPlayer.id, money: currentPlayer.money - Constants.bailAmount) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            databaseManager.updateLog(message: String(
                format: Constants.paidBail,
                currentPlayer.name,
                Constants.bailAmount
            )) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            rollDice()
        } else {
            databaseManager.updateLog(message: String(
                format: Constants.insufficientBail,
                currentPlayer.name,
                Constants.bailAmount
            )) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
            if playerManager.getCurrentPlayer().id == playerManager.getCurrentUserId() {
                alertManager.showNoMoneyAlert(
                    amount: Constants.bailAmount,
                    payCompletion: {
                        self.databaseManager.updatePlayerMoney(playerID: currentPlayer.id, money: currentPlayer.money - Constants.bailAmount) { [weak self] result in
                            self?.handleDatabaseResult(result)
                        }
                        self.rollDice()
                    },
                    nextTernAction: { self.nextTurn() }
                )
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
