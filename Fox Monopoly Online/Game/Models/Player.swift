//
//  Player.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 11.02.2025.
//

import UIKit

/// Модель игрока
struct Player: Equatable {
    /// Идентификатор
    let id: String
    /// Имя
    let name: String
    /// Текущая позиция
    var position: Int = .zero
    /// Цвет
    var color: UIColor
    /// Сумма денег
    var money: Int = 15_000
    /// Флаг текущего игрока
    var current: Bool
    /// Флаг активности игрока
    var isActive: Bool = true
    /// Флаг тюрьмы
    var inJail: Bool = false
    /// Колличество попыток в тюрьме
    var jailAttempts: Int = .zero
    /// Флаг хода в обратном направлении
    var isMoveBack: Bool = false
    /// Сумма долга
    var amountDebt: Int = .zero
}

/// Структура первоначальной передачи игрока
struct PlayerData {
    /// Идентификатор
    let uid: String
    /// Имя
    let name: String
}
