//
//  LobbyFactory.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import UIKit

protocol LobbyFactoryProtocol {

    /// Создать экран лобби
    /// - Parameter delegate: делалегат координатора
    /// - Returns: экран Лобби
    func makeLobbyScreen(delegate: LobbyScreenDelegate) -> UIViewController

    /// Создать координатор экрана Ожидания
    /// - Parameters:
    ///   - delegate: делегат координатора
    ///   - gameId: идентификатор игры
    ///   - navigationController: навигационный контроллер
    /// - Returns: координатор экрана Ожидания
    func showWaitingRoomScreen(
        delegate: WaitingRoomCoordinatorDelegate,
        gameId: String,
        navigationController: UINavigationController
    ) -> Coordinator
}

final class LobbyFactory: LobbyFactoryProtocol {

    func makeLobbyScreen(delegate: LobbyScreenDelegate) -> UIViewController {
         LobbyAssembly().createModule(delegate: delegate)
    }

    func showWaitingRoomScreen(
        delegate: WaitingRoomCoordinatorDelegate,
        gameId: String,
        navigationController: UINavigationController
    ) -> Coordinator {
        let waitingCoordinator = WaitingRoomCoordinator(
            navigationController: navigationController,
            gameId: gameId
        )
        waitingCoordinator.delegate = delegate
        return waitingCoordinator
    }
}
