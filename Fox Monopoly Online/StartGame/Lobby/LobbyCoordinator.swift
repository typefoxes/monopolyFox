//
//  LobbyCoordinator.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import UIKit
import FirebaseAuth

final class LobbyCoordinator: BaseCoordinator {

    // MARK: - Constants

    private enum Constants {
        static let errorTitle: String = "Ошибка"
        static let confirmTitle: String = "Ok"
        static let roomCodeTitle: String = "Введите код комнаты"
        static let joinTitle: String = "Присоединиться"
        static let cancelTitle: String = "Отмена"
        static let emptyErrorMessage: String = "Поле не может быть пустым"
    }

    // MARK: - Private properties

    private let factory: LobbyFactoryProtocol

    // MARK: - Lifecycle

    init(navigationController: UINavigationController, factory: LobbyFactoryProtocol) {
        self.factory = factory
        super.init(navigationController: navigationController)
    }

    override func start() {
        showLobbyScreen()
    }

    // MARK: - Private methods

    private func showLobbyScreen() {
        let screen = factory.makeLobbyScreen(delegate: self)
        push(screen)
    }
}

// MARK: - LobbyScreenDelegate

extension LobbyCoordinator: LobbyScreenDelegate {

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.confirmTitle, style: .cancel))
        present(alert, animated: true)
    }

    func showWaitingRoomScreen(gameId: String) {
        let coordinator = factory.showWaitingRoomScreen(
            delegate: self,
            gameId: gameId,
            navigationController: navigationController
        )
        coordinate(to: coordinator)
    }

    func joinGame(user: User, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(
            title: Constants.roomCodeTitle,
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField()

        let joinAction = UIAlertAction(title:Constants.joinTitle, style: .default) { _ in
            if let textField = alert.textFields?.first, let gameID = textField.text, !gameID.isEmpty {
                completion(gameID)
            } else {
                self.showAlert(title: Constants.errorTitle, message: Constants.emptyErrorMessage)
            }
        }

        alert.addAction(joinAction)
        alert.addAction(UIAlertAction(title: Constants.cancelTitle, style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - WaitingRoomCoordinatorDelegate

extension LobbyCoordinator: WaitingRoomCoordinatorDelegate {

    func didFinishWaitingRoomCoordinator(_ coordinator: BaseCoordinator) {
        removeChild(coordinator)
    }
}
