//
//  GameModel.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.02.2025.
//
import UIKit
import Foundation

enum GameModel {
    /// Запросы/действия в игровой логике
    enum Request {
        /// Начало игры
        case startGame
        /// Выбор игрока (индекс, источник)
        case didSelectPlayer(index: Int, sourceView: UIView)
        // Выбор свойства поля (выбраное поле, источник)
        case didSelectProperty(property: Property, sourceView: UIView)
        /// Бросить кубики
        case rollDice
        /// Анимированное движение фишек
        case animateMovement(stepsRemaining: Int)
        /// Предложить договор
        case proposeTrade(_ model: TradeViewModel)
        /// Покинуть игру
        case exitGame
    }
}

/// Модель данных для меню управления полем
struct PropertyMenuViewModel {
    /// Выбранное поле
    let property: Property
    /// Источник
    let sourceView: UIView
    /// Текущий игрок
    let activePlayer: Player
    /// Действие при нажатии на "Строить"
    let buildAction: (() -> Void)?
    /// Действие при нажатии на "Продать"
    let sellAction: (() -> Void)?
    /// Действие при нажатии на "Заложить"
    let mortgageAction: (() -> Void)?
    /// Действие при нажатии на "Выкупить"
    let redeemAction: (() -> Void)?
}

/// Модель данных для меню игрока
struct PlayerMenuViewModel {
    /// Выбранный игрок
    let player: Player
    /// Источник
    let sourceView: UIView
    /// Текущий игрок
    let activePlayer: Player
    /// Действие при нажатии на "Сдаться"
    let surrenderAction: () -> Void
    /// Действие при нажатии на "Предложить обмен"
    let tradeAction: () -> Void
}

/// Модель данных для экрана торговли
struct TradeScreenModel {
    /// Данные текущего обмена
    let trade: TradeViewModel
    /// Действие при подтверждении обмена
    let acceptAction: () -> Void
}

/// Модель данных для аукциона
struct AuctionData {
    /// Позиция свойства на игровом поле
    let propertyPosition: Int
    /// Начальная цена аукциона
    let propertyPrice: Int
    /// Текущая ставка
    var currentBid: Int
    /// Список ID игроков, участвующих в аукционе
    var auctionPlayers: [String]
    /// Индекс текущего игрока, делающего ставку
    var currentBidderIndex: Int?
}

/// Модель данных для предложения обмена между игроками
struct TradeProposal {
    /// ID игрока, инициирующего обмен
    var fromPlayer: String
    /// ID игрока, получающего предложение
    var toPlayer: String
    /// Список позиций свойств для передачи от fromPlayer
    var fromPlayerProperties: [Int]?
    /// Список позиций свойств для передачи от toPlayer
    var toPlayerProperties: [Int]?
    /// Сумма денег, предлагаемая от fromPlayer
    var fromPlayerMoney: Int
    /// Сумма денег, запрашиваемая от toPlayer
    var toPlayerMoney: Int
}

/// Модель данных для управления отелями на собственности
struct HotelsData {
    /// Позиция свойства на игровом поле
    var propertyId: Int
    /// Количество отелей
    var count: Int
}
