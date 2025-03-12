//
//  WaitingRoomInteractor.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import UIKit

protocol WaitingRoomInteractor: AnyObject {
    /// Обработка запросов view
    /// - Parameter request: запрос
    func handleRequest(_ request: WaitingRoomModel.Request)
}

protocol WaitingRoomScreenDelegate: AnyObject {

    /// Начать игру
    /// - Parameters:
    ///   - gameId: идентификатор игры
    ///   - players: данные игроков
    ///   - currentUserId: идентификатор текущего пользователя
    func startGame(
        gameId: String,
        players: [PlayerData],
        currentUserId: String
    )

    /// Скопировать код комнаты
    func showCopyFeedback()

    /// Выйти в лобби
    func exitToLobby()

    /// Показать алерт о выходе в лобби
    /// - Parameter completion: завершение
    func showExitAlert(completion: @escaping () -> Void)

    /// Показать алерт об ошибке
    /// - Parameter messege: код ошибки
    func showErrorAlert(messege: String)
}

final class WaitingRoomInteractorImpl {

    // MARK: - Constants

    private enum Constants {
        static let startedStatus: String = "started"
        static let roomKey: String = "Код комнаты:"
        static let minimumPlayersCount: Int = 1
        static let errorTitle: String = "Ошибка"
    }

    // MARK: - Private propeties

    private let authManager: AuthManagerProtocol
    private let databaseManager: FirebaseDatabaseManagerProtocol
    private let presenter: WaitingRoomPresenter
    private var players: [PlayerData]?
    private let gameId: String
    private var gameStatusHandle: UInt?
    private var playersObserverHandle: UInt?

    // MARK: - Public propeties

    weak var coordinator: WaitingRoomScreenDelegate?

    // MARK: - Lifecycle

    init(
        databaseManager: FirebaseDatabaseManagerProtocol,
        presenter: WaitingRoomPresenter,
        gameId: String,
        authManager: AuthManagerProtocol
    ) {
        self.databaseManager = databaseManager
        self.presenter = presenter
        self.gameId = gameId
        self.authManager = authManager
        setupObservers()
    }

    deinit {
        cleanupBeforeExit()
    }

    // MARK: - Private methods

    private func startGame() {
        databaseManager.updateGameStatus(gameID: gameId, status: Constants.startedStatus) { [weak self] result in
            switch result {
                case .success():
                    break
                case .failure(let error):
                    self?.coordinator?.showErrorAlert(messege: error.localizedDescription)
            }
        }
    }

    private func setupObservers() {
        observePlayers()
        observeGameStatus()
    }

    private func observePlayers() {
        guard playersObserverHandle == nil else { return }
        let gameId = self.gameId

        playersObserverHandle = databaseManager.observePlayers(gameID: gameId) { [weak self] result in
            switch result {
                case .success(let players):
                    self?.players = players
                    self?.presenter.displayWaitingRoom(model: WaitingRoomModel.ViewModel(
                        gameId: Constants.roomKey + " \(gameId)",
                        players: players
                    ))
                    self?.checkHostPrivileges()
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }
    }

    private func observeGameStatus() {
        gameStatusHandle = databaseManager.observeGameStatus(gameID: gameId) {  [weak self] result in
            switch result {
                case .success(let status):
                    if status == Constants.startedStatus {
                        self?.notifyGameStart()
                    }
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }
    }

    private func checkHostPrivileges() {
        databaseManager.getHostId(gameID: gameId) { [weak self] result in
            switch result {
                case .success(let hostId):
                    guard let self = self,
                          let currentUserId = self.authManager.currentUser()?.uid,
                          hostId == currentUserId, let players = players else { return }
                    self.presenter.showStartButton(players.count > Constants.minimumPlayersCount)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
        }
    }

    private func notifyGameStart() {
        guard let currentUserId = authManager.currentUser()?.uid, let players = players else { return }
        coordinator?.startGame(
            gameId: gameId,
            players: players,
            currentUserId: currentUserId
        )
    }

    private func exitGame() {
        guard let userID = authManager.currentUser()?.uid else { return }

        databaseManager.leaveGame(gameID: gameId, userID: userID) { [weak self] result in
            switch result {
                case .success:
                    self?.cleanupBeforeExit()
                    self?.coordinator?.exitToLobby()
                case .failure(let error):
                    self?.coordinator?.showErrorAlert(messege: error.localizedDescription)
            }
        }
    }

    private func cleanupBeforeExit() {
        if let playersHandle = playersObserverHandle {
            databaseManager.removeObserver(with: playersHandle)
            playersObserverHandle = nil
        }

        if let gameHandle = gameStatusHandle {
            databaseManager.removeObserver(with: gameHandle)
            gameStatusHandle = nil
        }
    }
}

// MARK: - WaitingRoomInteractor

extension WaitingRoomInteractorImpl: WaitingRoomInteractor {

    func handleRequest(_ request: WaitingRoomModel.Request) {
        switch request {
            case .startGame:
                startGame()
            case .showCopyFeedback:
                coordinator?.showCopyFeedback()
            case .showExitAlert:
                coordinator?.showExitAlert { [weak self] in
                    self?.exitGame()
            }
        }
    }
}
