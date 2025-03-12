//
//  LobbyModel.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//
import UIKit

enum LobbyModel {
    /// Запросы
    enum Request {
        /// авторизоваться
        case signIn(controller: UIViewController)
        /// разлогиниться
        case singOut
        /// отобразить экран лобби
        case displayLobby
        /// создать игру
        case createGame
        /// присоединиться к игре
        case joinGame
    }

    /// Модель панели игрока
    struct ViewModel {
        /// имя
        let name: String?
        /// изображение
        let image: UIImage?
        /// флаг авторизации
        let auth: Bool
    }
}
