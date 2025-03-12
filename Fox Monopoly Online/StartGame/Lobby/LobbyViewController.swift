//
//  LobbyViewController.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import UIKit
import FirebaseAuth
import Lottie
import SwiftUI

protocol LobbyViewDelegate: AnyObject {
    /// Отобразить экран Лобби
    /// - Parameter model: модель данных экрана
    func displayLobby(model: LobbyModel.ViewModel)
}

final class LobbyViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let joinTitle: String = "Присоединиться"
        static let authTitle: String = "Авторизоваться"
        static let createTitle: String = "Создать игру"
        static let logoutTitle: String = "Выйти"
        static let animationJSON: String = "Money"
        static let defaultButtonsHeight: CGFloat = 50
        static let buttonWidthRatio: CGFloat = 0.7
        static let userImageSize = CGSize(width: 40, height: 40)
        static let userImageCornerRadius: CGFloat = 20
        static let logoutButtonWidth: CGFloat = 70
        static let userNameLabelTrailing: CGFloat = 10
        static let defaultPadding: CGFloat = 20
        static let buttonsCornerRadius: CGFloat = 8
        static let stackViewSpacing: CGFloat = 10
        static let fontSize: CGFloat = 20
        static let animationDuration: CGFloat = 0.3
    }

    // MARK: - Private properties

    private lazy var userPhotoImage: UIImageView = {
        let userPhotoImage = UIImageView()
        userPhotoImage.translatesAutoresizingMaskIntoConstraints = false
        userPhotoImage.contentMode = .scaleAspectFill
        userPhotoImage.isHidden = true
        userPhotoImage.clipsToBounds = true
        userPhotoImage.layer.cornerRadius = Constants.userImageCornerRadius
        return userPhotoImage
    }()

    private lazy var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        userNameLabel.textColor = .white
        userNameLabel.isHidden = true
        return userNameLabel
    }()

    private lazy var authButton: UIButton = {
        let authButton = UIButton()
        authButton.translatesAutoresizingMaskIntoConstraints = false
        authButton.setTitle(Constants.authTitle, for: .normal)
        authButton.backgroundColor = .greens
        authButton.titleLabel?.textColor = .white
        authButton.layer.cornerRadius = Constants.buttonsCornerRadius
        authButton.addTarget(self, action:  #selector(googleSignInTapped), for: .touchUpInside)
        return authButton
    }()

    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle(Constants.logoutTitle, for: .normal)
        logoutButton.backgroundColor = .reds
        logoutButton.layer.cornerRadius = Constants.buttonsCornerRadius
        logoutButton.isHidden = true
        logoutButton.addTarget(self, action:  #selector(logoutTapped), for: .touchUpInside)
        return logoutButton
    }()

    private lazy var createButton: UIButton = {
        let createButton = UIButton()
        createButton.backgroundColor = .greens
        createButton.titleLabel?.textColor = .white
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setTitle(Constants.createTitle, for: .normal)
        createButton.layer.cornerRadius = Constants.buttonsCornerRadius
        createButton.addTarget(self, action: #selector(createGame), for: .touchUpInside)
        return createButton
    }()

    private lazy var joinButton: UIButton = {
        let joinButton = UIButton()
        joinButton.backgroundColor = .blues
        joinButton.titleLabel?.textColor = .white
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.setTitle(Constants.joinTitle, for: .normal)
        joinButton.layer.cornerRadius = Constants.buttonsCornerRadius
        joinButton.addTarget(self, action: #selector(joinGame), for: .touchUpInside)
        return joinButton
    }()

    private lazy var buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = Constants.stackViewSpacing
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        return buttonStackView
    }()

    private lazy var animationView = LottieAnimationView()
    private let interactor: LobbyInteractor

    // MARK: - Lifecycle

    init(interactor: LobbyInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSubviews()
        setupAnimation()
        interactor.handleRequest(.displayLobby)
    }

    // MARK: - Private methods

    private func setupSubviews() {
        view.addSubviews(animationView, userPhotoImage, userNameLabel, buttonStackView, logoutButton)
        setupConstraints()
    }

    private func setupConstraints() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userPhotoImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.defaultPadding),
            userPhotoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.defaultPadding),
            userPhotoImage.widthAnchor.constraint(equalToConstant: Constants.userImageSize.width),
            userPhotoImage.heightAnchor.constraint(equalToConstant: Constants.userImageSize.height),

            logoutButton.centerYAnchor.constraint(equalTo: userPhotoImage.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.defaultPadding),
            logoutButton.heightAnchor.constraint(equalTo: userPhotoImage.heightAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.logoutButtonWidth),

            userNameLabel.leadingAnchor.constraint(equalTo: userPhotoImage.trailingAnchor, constant: Constants.defaultPadding),
            userNameLabel.centerYAnchor.constraint(equalTo: userPhotoImage.centerYAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: logoutButton.leadingAnchor, constant: -Constants.userNameLabelTrailing),

            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func setupButtonsConstraints(auth: Bool) {
        if auth {
            NSLayoutConstraint.activate([
                createButton.heightAnchor.constraint(equalToConstant: Constants.defaultButtonsHeight),
                createButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.buttonWidthRatio),
                joinButton.heightAnchor.constraint(equalToConstant: Constants.defaultButtonsHeight),
                joinButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.buttonWidthRatio),
            ])
        } else {
            NSLayoutConstraint.activate([
                authButton.heightAnchor.constraint(equalToConstant: Constants.defaultButtonsHeight),
                authButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.buttonWidthRatio)
            ])
        }
    }

    private func setupAnimation() {
        let animation = LottieAnimation.named(Constants.animationJSON)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }

    // MARK: - Actions

    @objc private func googleSignInTapped() {
        interactor.handleRequest(.signIn(controller: self))
    }

    @objc private func logoutTapped() {
        interactor.handleRequest(.singOut)
    }

    @objc private func createGame() {
        interactor.handleRequest(.createGame)
    }

    @objc private func joinGame() {
        interactor.handleRequest(.joinGame)
    }
}

// MARK: - LobbyViewDelegate

extension LobbyViewController: LobbyViewDelegate {

    func displayLobby(model: LobbyModel.ViewModel) {
        buttonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if model.auth {
            buttonStackView.addArrangedSubview(createButton)
            buttonStackView.addArrangedSubview(joinButton)
            userPhotoImage.isHidden = false
            userNameLabel.isHidden = false
            logoutButton.isHidden = false
            userPhotoImage.image = model.image
            userNameLabel.text = model.name
        } else {
            userPhotoImage.isHidden = true
            userNameLabel.isHidden = true
            logoutButton.isHidden = true
            buttonStackView.addArrangedSubview(authButton)
        }

        setupButtonsConstraints(auth: model.auth)
    }
}
