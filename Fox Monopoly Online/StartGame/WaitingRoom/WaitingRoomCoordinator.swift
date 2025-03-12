//
//  WaitingRoomCoordinator.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import UIKit

protocol WaitingRoomCoordinatorDelegate: AnyObject {
    /// Закрытие координатора комнаты ожидания
    /// - Parameter coordinator: координатор
    func didFinishWaitingRoomCoordinator(_ coordinator: BaseCoordinator)
}

final class WaitingRoomCoordinator: BaseCoordinator {

    // MARK: - Constants

    private enum Constants {
        static let copyTitle: String = "Скопировано!"
        static let exitTitle: String = "Выход из комнаты"
        static let exitMessage: String = "Вы уверены, что хотите выйти из комнаты?"
        static let cancelTitle: String = "Отмена"
        static let confirmExitTitle: String = "Выйти"
        static let errorTitle: String = "Ошибка"
        static let confirmTitle: String = "Ok"
        static let deadline: CGFloat = 0.5
    }

    // MARK: - Private propeties

    private let factory = WaitingRoomFactory()
    private let gameId: String

    // MARK: - Public propeties

    weak var delegate: WaitingRoomCoordinatorDelegate?

    // MARK: - Lifecycle

    init(navigationController: UINavigationController, gameId: String) {
        self.gameId = gameId
        super.init(navigationController: navigationController)
    }

    override func start() {
        showWaitingRoomScreen()
    }

    // MARK: - Private methods

    private func showWaitingRoomScreen() {
        let screen = factory.makeWaitingRoomFactory(gameId: gameId, delegate: self)
        push(screen)
    }
}

// MARK: - WaitingRoomScreenDelegate

extension WaitingRoomCoordinator: WaitingRoomScreenDelegate {

    func startGame(gameId: String, players: [PlayerData], currentUserId: String) {
        let coordinator = factory.makeGameCoordinator(
            navigationController: navigationController,
            gameId: gameId,
            players: players,
            currentUserId: currentUserId,
            delegate: self
        )
        coordinate(to: coordinator)
    }

    func showCopyFeedback() {
        let alert = UIAlertController(
            title: Constants.copyTitle,
            message: nil,
            preferredStyle: .alert
        )

        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.deadline) {
                alert.dismiss(animated: true)
            }
        }
    }

    func showExitAlert(completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: Constants.exitTitle,
            message: Constants.exitMessage,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: Constants.cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.confirmExitTitle, style: .destructive) { _ in
            completion()
        })

        present(alert, animated: true)
    }

    func showErrorAlert(messege: String) {
        let alert = UIAlertController(
            title: Constants.errorTitle,
            message: messege,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: Constants.confirmTitle, style: .cancel))

        present(alert, animated: true)
    }

    func exitToLobby() {
        pop(animated: true)
        delegate?.didFinishWaitingRoomCoordinator(self)
    }
}

extension WaitingRoomCoordinator: GameCoordinatorDelegate {

    func didFinishGameCoordinator(_ coordinator: BaseCoordinator) {
        removeChild(coordinator)
        delegate?.didFinishWaitingRoomCoordinator(self)
    }
}
