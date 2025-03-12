//
//  WaitingRoomFactory.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import UIKit

protocol WaitingRoomFactoryProtocol {

    /// Создать экран ожидания
    /// - Parameters:
    ///   - gameId: идентификатор игры
    ///   - delegate: делегат координатора
    /// - Returns: экран ожидания
    func makeWaitingRoomFactory(gameId: String, delegate: WaitingRoomScreenDelegate) -> UIViewController

    /// Создать координатор игры
    /// - Parameters:
    ///   - navigationController: контроллер навигации
    ///   - gameId: идентификатор игры
    ///   - players: данные игроков
    ///   - currentUserId: идентификатор текущего пользователя
    /// - Returns: координатор игры
    func makeGameCoordinator(
        navigationController: UINavigationController,
        gameId: String,
        players: [PlayerData],
        currentUserId: String,
        delegate: GameCoordinatorDelegate
    ) -> any Coordinator
}

final class WaitingRoomFactory: WaitingRoomFactoryProtocol {

    func makeGameCoordinator(
        navigationController: UINavigationController,
        gameId: String,
        players: [PlayerData],
        currentUserId: String,
        delegate: GameCoordinatorDelegate
    ) -> any Coordinator {
        let factory: GameFactoryProtocol = GameFactory()
        let coordinator = GameCoordinator(
            navigationController: navigationController,
            factory: factory,
            gameId: gameId,
            players: players,
            currentUserId: currentUserId
        )
        coordinator.delegate = delegate
        return coordinator
    }

    func makeWaitingRoomFactory(gameId: String, delegate: WaitingRoomScreenDelegate) -> UIViewController {
        WaitingRoomAssembly().createScreen(gameId: gameId, delegate: delegate)
    }

}
