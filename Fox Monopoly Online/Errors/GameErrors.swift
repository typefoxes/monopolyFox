//
//  GameErrors.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 04.03.2025.
//

import Foundation

enum GameError: Error {
    case invalidPlayerIndex
    case playerNotFound
    case propertyNotFound
    case insufficientFunds
    case databaseError
    case invalidTradeProposal
}

extension GameError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .invalidPlayerIndex:
            return "Некорректный индекс игрока"
        case .playerNotFound:
            return "Игрок не найден"
        case .propertyNotFound:
            return "Поле не найдено"
        case .insufficientFunds:
            return "Недостаточно средсв"
        case .databaseError:
            return "Ошибка в базе данныйх Firebase"
        case .invalidTradeProposal:
            return "Ошибка в предложении сделки"
        }
    }
}
