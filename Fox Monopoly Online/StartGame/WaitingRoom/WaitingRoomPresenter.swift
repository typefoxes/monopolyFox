//
//  WaitingRoomPresenter.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

protocol WaitingRoomPresenter: AnyObject {

    /// Отобразить экран ожидания
    /// - Parameter model: модель
    func displayWaitingRoom(model: WaitingRoomModel.ViewModel)

    /// Показать кнопку начать игру
    /// - Parameter show: флаг показа
    func showStartButton(_ show: Bool)
}

final class WaitingRoomPresenterImpl: WaitingRoomPresenter {

    weak var view: WaitingRoomViewDelegate?

    func displayWaitingRoom(model: WaitingRoomModel.ViewModel) {
        view?.displayWaitingRoom(model: model)
    }

    func showStartButton(_ show: Bool) {
        view?.showStartButton(show)
    }
}
