//
//  LobbyInterctor.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import FirebaseAuth
import UIKit

protocol LobbyInteractor: AnyObject {
    /// Обработка запросов view
    /// - Parameter request: запрос
    func handleRequest(_ request: LobbyModel.Request)
}

protocol LobbyScreenDelegate: AnyObject {
    /// Показать экран ожидания
    /// - Parameter gameId: идентификатор игры
    func showWaitingRoomScreen(gameId: String)
    /// Присоединиться к игре
    /// - Parameters:
    ///   - user: данные пользователя
    ///   - completion: комплишн
    func joinGame(user: User, completion: @escaping (String) -> Void)
    /// Показать уведомление
    /// - Parameters:
    ///   - title: тайтл
    ///   - message: сообщение
    func showAlert(title: String, message: String)
}

final class LobbyInteractorImpl {

    // MARK: - Constants

    private enum Constants {
        static let errorTitle: String = "Ошибка"
        static let unknownErrorMessage: String = "Неизвестная ошибка"
        static let gameIdLength: Int = 6
    }

    // MARK: - Private properties

    private let authManager: AuthManagerProtocol
    private let databaseManager: FirebaseDatabaseManagerProtocol
    private let presenter: LobbyPresenter

    // MARK: - Public properties

    weak var coordinator: LobbyScreenDelegate?

    // MARK: - Lifecycle

    init(
        databaseManager: FirebaseDatabaseManagerProtocol,
        presenter: LobbyPresenter,
        authManager: AuthManagerProtocol
    ) {
        self.databaseManager = databaseManager
        self.presenter = presenter
        self.authManager = authManager
    }

    // MARK: - Private methods

    private func handleError(_ error: LobbyError) {
        let message: String
        switch error {
        case .auth(let authError):
            message = authError.localizedDescription
        case .game(let gameError):
            message = gameError.localizedDescription
        case .network(let networkError):
            message = networkError.localizedDescription
        case .unknownError:
            message = Constants.unknownErrorMessage
        }
        coordinator?.showAlert(title: Constants.errorTitle, message: message)
    }

    private func getCurrentUser() throws -> User {
        guard let user = authManager.currentUser() else {
            throw LobbyError.auth(.userNotAuthenticated)
        }
        return user
    }

    private func googleSignIn(_ controller: UIViewController) {
        authManager.signInWithGoogle(presentingViewController: controller) { result in
            switch result {
            case .success(let user):
                self.displayLobby(user: user)
            case .failure(let error):
                self.handleError(.auth(.googleSignInFailed(error)))
            }
        }
    }

    private func logoutTapped() {
        authManager.singOut()
        displayLobby(user: nil)
    }

    private func displayLobby(user: User? = nil) {
        var userPic: UIImage = .userPlaceholder

        getImage(imageUrl: user?.photoURL) { [weak self] image in
            guard let self = self else { return }

            if let image = image {
                userPic = image
            }

            let model = LobbyModel.ViewModel(
                name: user?.displayName,
                image: userPic,
                auth: user != nil
            )

            DispatchQueue.main.async {
                self.presenter.displayLobby(model: model)
            }
        }
    }

    private func loadImageAsync(url: URL?) async throws -> UIImage {
        guard let url = url else {
            throw LobbyError.network(.invalidURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw LobbyError.network(.imageLoadingFailed(URLError(.cannotDecodeContentData)))
        }

        return image
    }

    private func getImage(imageUrl: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = imageUrl else {
            completion(nil)
            return
        }

        Task {
            do {
                let image = try await loadImageAsync(url: url)
                completion(image)
            } catch {
                handleError(.network(.imageLoadingFailed(error)))
                completion(nil)
            }
        }
    }

    private func createGame() {
        do {
            let user = try getCurrentUser()
            let gameID = String(UUID().uuidString.prefix(Constants.gameIdLength))

            databaseManager.createGame(
                gameID: gameID,
                userID: user.uid,
                displayName: user.displayName
            ) { [weak self] result in
                switch result {
                case .success:
                    self?.coordinator?.showWaitingRoomScreen(gameId: gameID)
                case .failure(let error):
                    self?.handleError(.game(.gameCreationFailed(error)))
                }
            }
        } catch {
            handleError(error as? LobbyError ?? .unknownError)
        }
    }

    private func joinGame() {
        guard let user = authManager.currentUser() else { return }
        coordinator?.joinGame(user: user) { [weak self] gameID in
            self?.databaseManager.joinGame(gameID: gameID, userID: user.uid, displayName: user.displayName) { result in
                switch result {
                case .success:
                    self?.coordinator?.showWaitingRoomScreen(gameId: gameID)
                case .failure(let error):
                    self?.handleError(.game(.gameJoinFailed(error)))
                }
            }
        }
    }
}

// MARK: - LobbyInteractor

extension LobbyInteractorImpl: LobbyInteractor {

    func handleRequest(_ request: LobbyModel.Request) {
        switch request {
            case .signIn(let controller):
                googleSignIn(controller)
            case .singOut:
                logoutTapped()
            case .displayLobby:
                displayLobby(user: authManager.currentUser())
            case .createGame:
                createGame()
            case .joinGame:
                joinGame()
        }
    }
}
