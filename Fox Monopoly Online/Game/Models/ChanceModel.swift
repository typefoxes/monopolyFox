//
//  ChanceModel.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 15.02.2025.
//

import UIKit

/// Модель карточки шанс
struct ChanceCard {
    /// Описание действий
    let description: String
    /// Тип
    let type: ChanceType
}

/// Типы карточек шанс
enum ChanceType {
    case netflix
    case goToStart
    case modalWinner
    case sweetBun
    case lucky
    case buildings
    case birthday
    case random
    case backMove
    case fine
    case jail
    case goldenApple
    case extraMove
    case forwardAtThree
    case park
    case icecream
    case coffee
}
