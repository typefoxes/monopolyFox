//
//  PlayerManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 11.02.2025.
//

protocol PlayerManagerProtocol {
    /// Задать начальных игроков
    /// - Parameter players: массив моделей игроков
    func setPlayers(players: [Player])
    /// Передать ход следующему игроку
    func nextPlayer()
    /// Обновить деньги игрока
    /// - Parameters:
    ///   - playerId: идентификатор игрока
    ///   - money: сумма
    func updatePlayerMoney(playerId: String, money: Int)
    /// Получить  текущего активного игрока
    /// - Returns: Модель игрока
    func getCurrentPlayer() -> Player
    /// Назначить текущего игрока
    /// - Parameter index: индекс
    func setCurrentPlayer(index: Int)
    /// Получить всех игроков
    /// - Returns: массив моделей игроков
    func getPlayers() -> [Player]
    /// Отправить игрока в тюрьму
    /// - Parameter id: идентификатор игрока
    func sendPlayerToJail(id: String)
    /// Освободить игрока из тюрьмы
    /// - Parameter id: идентификатор игрока
    func releasePlayerFromJail(id: String)
    /// Обновить позицию игрока
    /// - Parameters:
    ///   - playerId: идентификатор игрока
    ///   - position: позиция
    func updatePlayerPosition(playerId: String, position: Int)
    /// Обновить количество попыток выбросить дубль в тюрьме
    /// - Parameter id: идентификатор игрока
    func updateJailAttempts(id: String)
    /// Игрок сдался
    /// - Parameter playerId: идентификатор игрока
    func surrender(playerId: String)
    /// Получить игрока по индексу
    /// - Parameter index: индекс
    /// - Returns: модель игрока
    func getPlayer(index: Int) throws -> Player
    /// Получить индекс текущего игрока
    /// - Returns: индекс
    func getCurrentPlayerIndex() -> Int
    /// Установить или сбросить следующий ход в обратном напровлении для игрока
    /// - Parameters:
    ///   - playerId: идентификатор игрока
    ///   - isMoveBack: флаг
    func setNextMoveToBack(playerId: String, isMoveBack: Bool)
    /// Найти игрока по идентификатору
    /// - Parameter id: идентификатору игрока
    /// - Returns: модель игрока
    func findPlayer(id: String) -> Player?
    /// Получить идентификатор авторизации на устройстве у игрока
    /// - Returns: идентификатор
    func getCurrentUserId() -> String
    /// Обновить сумму долга игрока
    /// - Parameters:
    ///   - playerId: идентификатору игрока
    ///   - amount: сумма долга
    func updateAmountDebt(playerId: String, amount: Int)
}

final class PlayerManager: PlayerManagerProtocol {

    // MARK: - Constants

    private enum Constants {
        static let one: Int = 1
        static let jailPosition: Int = 10
    }
    private var players: [Player] = []
    private let currentUserId: String

    private var currentPlayerIndex: Int = .zero

    init(currentUserId: String) {
        self.currentUserId = currentUserId
    }

    func updateAmountDebt(playerId: String, amount: Int) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].amountDebt += amount
        }
    }

    func getCurrentUserId() -> String {
        currentUserId
    }

    func setPlayers(players: [Player]) {
        self.players = players
    }

    func findPlayer(id: String) -> Player? {
        if let index = players.firstIndex(where: { $0.id == id }) {
            return players[index]
        }
        return nil
    }

    func nextPlayer() {
        players[currentPlayerIndex].current = false

        var nextIndex = (currentPlayerIndex + Constants.one) % players.count
        while !players[nextIndex].isActive {
            nextIndex = (nextIndex + Constants.one) % players.count
        }

        currentPlayerIndex = nextIndex
        players[currentPlayerIndex].current = true
    }

    func updatePlayerMoney(playerId: String, money: Int) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].money = money
        }
    }

    func getCurrentPlayer() -> Player {
        return players[currentPlayerIndex]
    }

    func setCurrentPlayer(index: Int) {
        players[currentPlayerIndex].current = false
        currentPlayerIndex = index
        players[currentPlayerIndex].current = true
    }

    func getPlayers() -> [Player] {
        return players
    }

    func sendPlayerToJail(id: String) {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].inJail = true
            players[index].position = Constants.jailPosition
            players[index].jailAttempts = .zero
        }
    }

    func releasePlayerFromJail(id: String) {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].inJail = false
            players[index].jailAttempts = .zero
        }
    }

    func updatePlayerPosition(playerId: String, position: Int) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].position = position
        }
    }

    func updateJailAttempts(id: String) {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].jailAttempts += Constants.one
        }
    }

    func surrender(playerId: String) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].isActive = false
            players[index].money = .zero

            if currentPlayerIndex >= players.count {
                currentPlayerIndex = .zero
            }
        }
    }

    func getPlayer(index: Int) throws -> Player {
        guard index >= .zero && index < players.count else {
            throw GameError.invalidPlayerIndex
        }
        return players[index]
    }

    func getCurrentPlayerIndex() -> Int {
       return currentPlayerIndex
    }

    func setNextMoveToBack(playerId: String, isMoveBack: Bool) {
        players = players.map {
            var updatedplayer = $0

            if updatedplayer.id == playerId {
                updatedplayer.isMoveBack = isMoveBack
            }

            return updatedplayer
        }
    }
}

