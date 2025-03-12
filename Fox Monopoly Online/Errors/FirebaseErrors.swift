//
//  FirebaseErrors.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 10.03.2025.
//

import Foundation

enum FirebaseDatabaseManagerError: Error, LocalizedError {
    case invalidData(message: String)
    case invalidGameID
    case snapshotNotFound(message: String)
    case invalidPlayerData
    case invalidPropertyData
    case invalidAuctionData
    case invalidTradeData
    case invalidHotelData
    case invalidPath
    case networkError(Error)
    case gameNotFound
    case parsingError
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidData(let message):
            return "Некорректные данные: \(message)"
        case .invalidGameID:
            return "Неверный идентификатор игры"
        case .snapshotNotFound(let message):
            return "Данные не найдены: \(message)"
        case .invalidPlayerData:
            return "Ошибка в данных игрока"
        case .invalidPropertyData:
            return "Ошибка в данных собственности"
        case .invalidAuctionData:
            return "Ошибка в данных аукциона"
        case .invalidTradeData:
            return "Ошибка в данных обмена"
        case .invalidHotelData:
            return "Ошибка в данных отеля"
        case .invalidPath:
            return "Неверный путь к данным"
        case .networkError(let error):
            return "Сетевая ошибка: \(error.localizedDescription)"
        case .gameNotFound:
            return "Игра не найдена"
        case .parsingError:
            return "Ошибка обработки данных"
        case .unknownError:
            return "Неизвестная ошибка"
        }
    }
}
