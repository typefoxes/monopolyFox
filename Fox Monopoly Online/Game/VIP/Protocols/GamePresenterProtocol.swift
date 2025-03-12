//
//  GamePresenterProtocol.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.03.2025.
//

protocol GamePresenter: AnyObject {
    /// Старт игры
    func startGame()

    /// Добавть запись в лог на доске
    /// - Parameter message: сообщение
    func logOnBoard(message: String)

    /// Передвинуть фишку игрока с финальным действием
    /// - Parameters:
    ///   - stepsRemaining: осталось шагов
    ///   - position: позиция
    ///   - isLastStep: флаг последнего шага
    func movePlayer(stepsRemaining: Int, position: Int, isLastStep: Bool)

    /// Обновить информацию об игроках
    func updatePlayersInformation()

    /// Обновить информацию о поле
    func updateAllProperties()

    /// Передвинуть фишку игрока без финального действия
    /// - Parameters:
    ///   - position: позиция
    func movePlayerToPosition(position: Int)

    /// Игрок сдался
    /// - Parameter id: идентификатор игрока
    func playerSurrender(_ id: String)

    /// Удалить все алерты
    func removeAlerts()

    /// Показать вью торговли
    /// - Parameters:
    ///   - currentPlayer: предлагающий игрок
    ///   - tradingPlayer: принимающий игрок
    func showTradingView(currentPlayer: Player, tradingPlayer: Player)

    /// Обновить состояние кнопок алрета
    /// - Parameters:
    ///   - amount: сумма долга
    func updatePayButtonInAlert(amount: Int)
}
