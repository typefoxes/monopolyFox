//
//  GameInteractor.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 11.03.2025.
//

protocol GameInteractor: AnyObject {

    /// Обработать запрос
    /// - Parameter request: запрос
    func handleRequest(_ request: GameModel.Request)
}

protocol GameScreenDelegate: AnyObject {

    /// Показать алерт
    /// - Parameters:
    ///   - title: заголовок
    ///   - message: сообщение
    func showAlert(title: String, message: String)

    /// Показать меню игрока
    /// - Parameter model: модель меню
    func showPlayerMenu(_ model: PlayerMenuViewModel)

    /// Показать меню собственности
    /// - Parameter model: модель меню
    func showPropertyMenu(_ model: PropertyMenuViewModel)

    /// Показат экран торгов
    /// - Parameter model: модель
    func showTradeScreen(_ model: TradeScreenModel)

    /// Показать экран конец игры
    func presentEndGameScreen(winner: Player)

    /// Покинуть игру
    func exitGame()
}
