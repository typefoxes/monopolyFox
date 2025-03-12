//
//  WaitingViewController.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 04.02.2025.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

protocol WaitingRoomViewDelegate: AnyObject {

    /// Показать экран комнаты ожидания
    /// - Parameter model: модель
    func displayWaitingRoom(model: WaitingRoomModel.ViewModel)

    /// Показать кнопку начать игру
    /// - Parameter show: флаг показа
    func showStartButton(_ show: Bool)
}

final class WaitingViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let copyButtonSize = CGSize(width: 40, height: 40)
        static let copyButtonInsets: CGFloat = 20
        static let gameIdLabelHeight: CGFloat = 40
        static let gameIdLabelLeading: CGFloat = 50
        static let gameIdLabelTop: CGFloat = 20
        static let gameIdLabelTrailing: CGFloat = 10
        static let startButtonBottom: CGFloat = 100
        static let startButtonHeight: CGFloat = 50
        static let multiplier: CGFloat = 0.7
        static let tableViewTop: CGFloat = 10
        static let tableViewBottom: CGFloat = 20
        static let exitTitle: String = "Выйти"
        static let exitPictureName: String = "chevron.left"
        static let imagePadding: CGFloat = 8
        static let standardCornerRadius: CGFloat = 8
        static let copyButtonCornerRadius: CGFloat = 20
        static let fontSize: CGFloat = 20
        static let copyPictureName: String = "square.on.square"
        static let startGameTitle: String = "Начать игру"
        static let cellIdentifier: String = "cell"
    }

    // MARK: - Private properties

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        return tableView
    }()

    private lazy var startButton: UIButton = {
        let startButton = UIButton()
        startButton.isHidden = true
        startButton.setTitle(Constants.startGameTitle, for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.isEnabled = false
        startButton.layer.cornerRadius = Constants.standardCornerRadius
        startButton.backgroundColor = .greens
        startButton.titleLabel?.textColor = .white
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        return startButton
    }()

    private lazy var copyButton: UIButton = {
        let copyButton = UIButton()
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setImage(UIImage(systemName: Constants.copyPictureName), for: .normal)
        copyButton.tintColor = .white
        copyButton.layer.cornerRadius = Constants.copyButtonCornerRadius
        copyButton.clipsToBounds = true
        copyButton.backgroundColor = .greys
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        return copyButton
    }()

    private lazy var gameIdLabel: UILabel = {
        let gameIdLabel = UILabel()
        gameIdLabel.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .bold)
        gameIdLabel.translatesAutoresizingMaskIntoConstraints = false
        gameIdLabel.textColor = .white
        gameIdLabel.backgroundColor = .greys
        gameIdLabel.textAlignment = .center
        gameIdLabel.clipsToBounds = true
        gameIdLabel.layer.cornerRadius = Constants.standardCornerRadius
        return gameIdLabel
    }()

    private let interactor: WaitingRoomInteractor
    private var players: [PlayerData] = []

    // MARK: - Lifecycle

    init(interactor: WaitingRoomInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = false
        replaceBackButton()
        setupSubview()
    }

    // MARK: - Private methods

    private func replaceBackButton() {
        var config = UIButton.Configuration.plain()

        config.title = Constants.exitTitle
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: Constants.exitPictureName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        config.imagePlacement = .leading
        config.imagePadding = Constants.imagePadding

        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.interactor.handleRequest(.showExitAlert)
        })

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }

    private func setupSubview() {
        view.addSubviews(gameIdLabel, tableView, startButton, copyButton)

        NSLayoutConstraint.activate([
            copyButton.heightAnchor.constraint(equalToConstant: Constants.copyButtonSize.height),
            copyButton.widthAnchor.constraint(equalToConstant: Constants.copyButtonSize.width),
            copyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.copyButtonInsets),
            copyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.copyButtonInsets),

            gameIdLabel.heightAnchor.constraint(equalToConstant: Constants.gameIdLabelHeight),
            gameIdLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.gameIdLabelTop),
            gameIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.gameIdLabelLeading),
            gameIdLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -Constants.gameIdLabelTrailing),

            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.startButtonBottom),
            startButton.heightAnchor.constraint(equalToConstant: Constants.startButtonHeight),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.multiplier),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: gameIdLabel.bottomAnchor, constant: Constants.tableViewTop),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.multiplier),
            tableView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -Constants.tableViewBottom),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

        ])
    }

    // MARK: - Actions

    @objc func startGame() {
        interactor.handleRequest(.startGame)
    }

    @objc private func copyButtonTapped() {
        let textToCopy = gameIdLabel.text
        UIPasteboard.general.string = textToCopy
        interactor.handleRequest(.showCopyFeedback)
    }
}

// MARK: - WaitingRoomViewDelegate

extension WaitingViewController: WaitingRoomViewDelegate {

    func displayWaitingRoom(model: WaitingRoomModel.ViewModel) {
        gameIdLabel.text = model.gameId
        players =  model.players
        tableView.reloadData()
    }

    func showStartButton(_ show: Bool) {
        if show {
            self.startButton.isHidden = false
            self.startButton.isEnabled = true
        }
    }
}

// MARK: - UITableViewDataSource

extension WaitingViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        cell.textLabel?.text = players[indexPath.row].name
        return cell
    }
}
