//
//  GameFactory.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 04.03.2025.
//

import UIKit

protocol GameFactoryProtocol {
    /// Создать экран игрового поля
    /// - Parameters:
    ///   - gameID: идентификатор игры
    ///   - players: массив игроков
    ///   - currentUserId: идентификатор текущего пользователя
    ///   - delegate: делегат координатора
    /// - Returns: экран игрового поля
    func makeGameScreen(
        gameID: String,
        players: [PlayerData],
        currentUserId: String,
        delegate: GameScreenDelegate
    ) -> UIViewController

    /// Создать экран предложения о торгах
    /// - Parameter model: модель с предложением
    /// - Returns: экран торговли
    func makeTradeProposalScreen(_ model: TradeScreenModel) -> UIViewController

}

final class GameFactory: GameFactoryProtocol {

    func makeGameScreen(
        gameID: String,
        players: [PlayerData],
        currentUserId: String,
        delegate: GameScreenDelegate
    ) -> UIViewController {
        GameAssembly().createScreen(
            gameID: gameID,
            players: players,
            currentUserId: currentUserId,
            delegate: delegate
        )
    }

    func makeTradeProposalScreen(_ model: TradeScreenModel) -> UIViewController {
        let vc = ProposalViewController()
        vc.acceptAction = { model.acceptAction() }
        vc.configure(with: model.trade)
        vc.modalPresentationStyle = .formSheet
        return vc
    }
}
