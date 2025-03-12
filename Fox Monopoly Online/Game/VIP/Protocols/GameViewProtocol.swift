//
//  Untitled.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.03.2025.
//

protocol GameView: AnyObject {

    /// Начать игру
    func startGame()
    /// Вывести лог действий
    /// - Parameter message: сообщение
    func logOnBoard(message: String)

    /// Подвинуть игрока на 1 шаг
    /// - Parameters:
    ///   - stepsRemaining: осталось шагов
    ///   - position: позиция
    ///   - isLastStep: флаг последнего шага
    func moveOneStep(stepsRemaining: Int, position: Int, isLastStep: Bool)

    /// Показать кастомный алерт на поле
    /// - Parameters:
    ///   - model: модель
    ///   - twoButtons: флаг для двух кнопок
    func showAlert(model: AlertModel, twoButtons: Bool)

    /// Обновить информацию об игроках
    func updatePlayersInformation()
    /// Показать вью о составлении договора между игроками
    /// - Parameters:
    ///  - currentPlayer: предлагающий игрок
    ///  - traindingPlayer: получающий игрок
    func showTradingView(currentPlayer: Player, tradingPlayer: Player)

    /// Обновляет информацию всех полей
    func updateAllProperties()

    /// Обновить алерт
    /// - Parameters:
    ///   - amount: сумма долга
    func updatePayButtonInAlert(amount: Int)

    /// Передвинуть игрока на позицию
    /// - Parameters:
    ///   - position: позиция
    func movePlayerToPosition(position: Int)

    /// Игрок сдался
    /// - Parameter id: идентификатор игрока
    func playerSurrender(_ id: String)

    /// Удалить все алерты
    func removeAlerts()
}
