//
//  GameAssembly.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.02.2025.
//

import UIKit

protocol GameScreenAssembly: AnyObject {

    /// Создать экран Игры
    /// - Parameters:
    ///   - gameID: идентификатор игры
    ///   - players: массив игроков
    ///   - currentUserId: идентификатор текущего пользователя
    /// - Returns: Экран игры
    func createScreen(
        gameID: String,
        players: [PlayerData],
        currentUserId: String,
        delegate: GameScreenDelegate
    ) -> UIViewController
}

final class GameAssembly: GameScreenAssembly {

    func createScreen(
        gameID: String,
        players: [PlayerData],
        currentUserId: String,
        delegate: GameScreenDelegate
    ) -> UIViewController {

        let dependencies: DependenciesAssemblyProtocol = DependenciesAssembly(gameId: gameID)
        var alertManager = dependencies.alertManager
        var movementManager = dependencies.movementManager

        let presenter = GamePresenterImpl()

        let interactor = GameInteractorImpl(
            presenter: presenter,
            playerManager: dependencies.playerManager,
            propertyManager: dependencies.propertyManager,
            diceService: dependencies.diceService,
            players: players,
            currentUserID: currentUserId,
            databaseManager: dependencies.databaseManager,
            auctionManager: dependencies.auctionManager,
            movementManager: movementManager,
            alertManager: alertManager,
            tradeManager: dependencies.tradeManager
        )

        let viewController = GameViewController(
            interactor: interactor,
            playerManager: dependencies.playerManager,
            propertyManager: dependencies.propertyManager,
            logManager: dependencies.logManager,
            positionService: dependencies.positioningService
        )

        alertManager.delegate = viewController
        movementManager.delegate = viewController
        presenter.view = viewController
        interactor.coordinator = delegate

        return viewController
    }
}
