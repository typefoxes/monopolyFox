//
//  AuthManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 04.02.2025.
//

import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import UIKit
import FirebaseCore

protocol AuthManagerProtocol: AnyObject {
    /// Google авторизация
    /// - Parameters:
    ///   - presentingViewController: представляющий контроллер
    ///   - completion: комплишн
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void)
    /// Проверка авторизациии
    /// - Returns: значение
    func checkAuth() -> Bool
    /// Выйти из аккаунта
    func singOut()
    /// Получить текущего пользователя
    /// - Returns: данные пользователя
    func currentUser() -> User?
}

final class AuthManager: AuthManagerProtocol {

    // MARK: - AuthManagerProtocol

    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else if let user = authResult?.user {
                    completion(.success(user))
                }
            }
        }
    }

    func currentUser() -> User? {
        Auth.auth().currentUser
    }

    func checkAuth() -> Bool {
        Auth.auth().currentUser != nil
    }

    func singOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            debugPrint("Error singOut: \(error.localizedDescription)")
        }
    }
}

