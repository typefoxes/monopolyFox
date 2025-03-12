//
//  LobbyAssembler.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import UIKit

protocol LobbyAssemblyProtocol: AnyObject {
    /// Создать модуль Лобби
    func createModule(delegate: LobbyScreenDelegate) -> UIViewController
}

final class LobbyAssembly: LobbyAssemblyProtocol {

    func createModule(delegate: LobbyScreenDelegate) -> UIViewController {
        let dependencies: DependenciesAssemblyProtocol = DependenciesAssembly()
        let presenter = LobbyPresenterImpl()
        let interactor = LobbyInteractorImpl(
            databaseManager: dependencies.databaseManager,
            presenter: presenter,
            authManager: dependencies.authManager
        )
        let viewController = LobbyViewController(interactor: interactor)
        presenter.view = viewController
        interactor.coordinator = delegate
        return viewController
    }
}
