//
//  WaitingRoomAssembly.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import UIKit

protocol WaitingRoomAssemblyProtocol: AnyObject {

    /// Создать экран ожидания
    /// - Parameters:
    ///   - gameId: идентификатор игры
    ///   - delegate: делегат координатора
    /// - Returns: экран ожидания
    func createScreen(gameId: String, delegate: WaitingRoomScreenDelegate) -> UIViewController
}

final class WaitingRoomAssembly: WaitingRoomAssemblyProtocol {

    func createScreen(gameId: String, delegate: WaitingRoomScreenDelegate) -> UIViewController {
        let dependencies: DependenciesAssemblyProtocol = DependenciesAssembly(gameId: gameId)

        let presenter = WaitingRoomPresenterImpl()
        let interactor = WaitingRoomInteractorImpl(
            databaseManager:  dependencies.databaseManager,
            presenter: presenter,
            gameId: gameId,
            authManager: dependencies.authManager
        )

        let viewController = WaitingViewController(interactor: interactor)
        presenter.view = viewController
        interactor.coordinator = delegate

        return viewController
    }
}
