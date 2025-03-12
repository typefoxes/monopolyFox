//
//  LobbyErrors.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 04.03.2025.
//

import Foundation

enum LobbyError: Error {
    enum AuthError: Error {
        case googleSignInFailed(Error)
        case userNotAuthenticated
    }

    enum GameError: Error {
        case gameCreationFailed(Error)
        case gameJoinFailed(Error)
    }

    enum NetworkError: Error {
        case imageLoadingFailed(Error)
        case invalidURL
    }

    case auth(AuthError)
    case game(GameError)
    case network(NetworkError)
    case unknownError
}

// MARK: - LocalizedDescription

extension LobbyError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .auth(let authError):
            return authError.localizedDescription
        case .game(let gameError):
            return gameError.localizedDescription
        case .network(let networkError):
            return networkError.localizedDescription
        case .unknownError:
            return "Неизвестная ошибка"
        }
    }
}

extension LobbyError.AuthError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .googleSignInFailed(let error):
            return "Ошибка при входе через Google: \(error.localizedDescription)"
        case .userNotAuthenticated:
            return "Пользователь не аутентифицирован"
        }
    }
}

extension LobbyError.GameError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .gameCreationFailed(let error):
            return "Ошибка при создании игры: \(error.localizedDescription)"
        case .gameJoinFailed(let error):
            return "Ошибка при присоединении к игре: \(error.localizedDescription)"
        }
    }
}

extension LobbyError.NetworkError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .imageLoadingFailed(let error):
            return "Ошибка при загрузке изображения: \(error.localizedDescription)"
        case .invalidURL:
            return "Некорректный URL"
        }
    }
}
