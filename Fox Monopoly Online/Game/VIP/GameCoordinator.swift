//
//  GameCoordinator.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 04.03.2025.
//


import UIKit

protocol GameCoordinatorDelegate: AnyObject {
    /// Закрытие координатора игры
    /// - Parameter coordinator: координатор
    func didFinishGameCoordinator(_ coordinator: BaseCoordinator)
}

final class GameCoordinator: BaseCoordinator {

    // MARK: - Constants

    private enum Constants {
        static let confirmTitle: String = "Ok"
        static let surrenderTitle: String = "Сдаться"
        static let tradeTitle: String = "Договор"
        static let cancelTitle: String = "Отмена"
        static let redeemTitle: String = "Выкупить"
        static let mortgageTitle: String = "Заложить"
        static let sellTitle: String = "Продать"
        static let buildTitle: String = "Построить"
    }

    // MARK: - Private properties

    private let factory: GameFactoryProtocol
    private let gameId: String
    private let players: [PlayerData]
    private let currentUserId: String

    weak var delegate: GameCoordinatorDelegate?

    // MARK: - Lifecycle

    init(
        navigationController: UINavigationController,
        factory: GameFactoryProtocol,
        gameId: String,
        players: [PlayerData],
        currentUserId: String
    ) {
        self.factory = factory
        self.gameId = gameId
        self.players = players
        self.currentUserId = currentUserId
        super.init(navigationController: navigationController)
    }

    override func start() {
        showGameScreen()
    }

    // MARK: - Private methods

    private func showGameScreen() {
        let screen = factory.makeGameScreen(
            gameID: gameId,
            players: players,
            currentUserId: currentUserId,
            delegate: self
        )
        push(screen)
    }
}

// MARK: - GameScreenDelegate

extension GameCoordinator: GameScreenDelegate {

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.confirmTitle, style: .cancel))
        present(alert, animated: true)
    }

    func showPlayerMenu(_ model: PlayerMenuViewModel) {
        let alert = UIAlertController(title: model.player.name, message: nil, preferredStyle: .actionSheet)

        if let popover = alert.popoverPresentationController {
            popover.sourceView = model.sourceView
            popover.sourceRect = model.sourceView.bounds
            popover.permittedArrowDirections = [.up, .down]
        }

        if model.player.id == model.activePlayer.id {
            alert.addAction(UIAlertAction(title: Constants.surrenderTitle, style: .destructive, handler: { _ in
                model.surrenderAction()
            }))
        } else {
            if model.player.isActive {
                alert.addAction(UIAlertAction(title: Constants.tradeTitle, style: .default, handler: { _ in
                    model.tradeAction()
                }))
            }
        }

        alert.addAction(UIAlertAction(title: Constants.cancelTitle, style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    func showPropertyMenu(_ model: PropertyMenuViewModel) {
        let alert = UIAlertController(title: model.property.name, message: nil, preferredStyle: .actionSheet)

        if let popover = alert.popoverPresentationController {
            popover.sourceView = model.sourceView
            popover.sourceRect = model.sourceView.bounds
            popover.permittedArrowDirections = [.up, .down]
        }

        if model.activePlayer.id == model.property.owner {

            if let buildAction = model.buildAction {
                alert.addAction(UIAlertAction(title: Constants.buildTitle, style: .default, handler: { _ in
                    buildAction()
                }))
            }

            if let sellAction = model.sellAction {
                alert.addAction(UIAlertAction(title: Constants.sellTitle, style: .default, handler: { _ in
                    sellAction()
                }))
            }

            if let mortgageAction = model.mortgageAction {
                alert.addAction(UIAlertAction(title: Constants.mortgageTitle, style: .destructive, handler: { _ in
                    mortgageAction()
                }))
            }

            if let redeemAction = model.redeemAction {
                alert.addAction(UIAlertAction(title: Constants.redeemTitle, style: .default, handler: { _ in
                    redeemAction()
                }))
            }
        }

        alert.addAction(UIAlertAction(title: Constants.cancelTitle, style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    func showTradeScreen(_ model: TradeScreenModel) {
        let screen = factory.makeTradeProposalScreen(model)
        present(screen, animated: true, completion: nil)
    }

    func presentEndGameScreen(winner: Player) {
        let winnerVC = WinnerViewController(winnerName: winner.name)
        winnerVC.modalPresentationStyle = .fullScreen
        winnerVC.delegate = self
        present(winnerVC, animated: true, completion: nil)
    }

    func exitGame() {
        didTapCloseButton()
    }
}

extension GameCoordinator: WinnerViewControllerDelegate {
    func didTapCloseButton() {
        dismiss(animated: true) {
            self.popToRootViewController()
            self.delegate?.didFinishGameCoordinator(self)
        }
    }
}
