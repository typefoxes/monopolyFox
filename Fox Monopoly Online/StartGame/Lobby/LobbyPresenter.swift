//
//  LobbyPresenter.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

protocol LobbyPresenter: AnyObject {

    /// Отобразить экран Лобби
    /// - Parameter model: модель данных экрана
    func displayLobby(model: LobbyModel.ViewModel)
}

final class LobbyPresenterImpl: LobbyPresenter {

    weak var view: LobbyViewDelegate?

    func displayLobby(model: LobbyModel.ViewModel) {
        view?.displayLobby(model: model)
    }
}
