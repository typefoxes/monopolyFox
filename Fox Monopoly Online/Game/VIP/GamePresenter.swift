//
//  GamePresenter.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.02.2025.
//

import UIKit

final class GamePresenterImpl: GamePresenter {

    weak var view: GameView?

    // MARK: - Private properties

    func showTradingView(currentPlayer: Player, tradingPlayer: Player) {
        view?.showTradingView(currentPlayer: currentPlayer, tradingPlayer: tradingPlayer)
    }

    func removeAlerts() {
        view?.removeAlerts()
    }

    func playerSurrender(_ id: String) {
        view?.playerSurrender(id)
    }

    func movePlayerToPosition(position: Int) {
        view?.movePlayerToPosition(position: position)
    }

    func startGame() {
        view?.startGame()
    }

    func logOnBoard(message: String) {
        view?.logOnBoard(message: message)
    }

    func movePlayer(stepsRemaining: Int, position: Int, isLastStep: Bool) {
        view?.moveOneStep(stepsRemaining: stepsRemaining, position: position, isLastStep: isLastStep)
    }

    func updatePlayersInformation() {
        view?.updatePlayersInformation()
    }

    func updateAllProperties() {
        view?.updateAllProperties()
    }

    func updatePayButtonInAlert(amount: Int) {
        view?.updatePayButtonInAlert(amount: amount)
    }
}
