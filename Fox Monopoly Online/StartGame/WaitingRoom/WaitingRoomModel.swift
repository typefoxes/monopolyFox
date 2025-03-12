//
//  WaitingRoomModel.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

enum WaitingRoomModel {
    /// Запросы
    enum Request {
        /// начать игру
        case startGame
        /// скопировать код комнаты
        case showCopyFeedback
        /// выйти
        case showExitAlert
    }

    /// Модель комнаты
    struct ViewModel {
        /// идентификатор игры
        let gameId: String
        /// данные игроков
        let players: [PlayerData]
    }
}
