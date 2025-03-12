//
//  GameViewController.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 04.02.2025.


import UIKit

final class GameViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let defaultPaddings: CGFloat = 10
        static let maxCards: CGFloat = 13
        static let numberOfCardsInSqare: CGFloat = 2
        static let collectionMaxHeight: CGFloat = 110
        static let collectionMinSpacing: CGFloat = 5
        static let alertViewTop: CGFloat = 20
        static let alertMaxHeight: CGFloat = 130
        static let animationDuration: TimeInterval = 0.3
        static let cellIdentifier: String = "PlayerCollectionViewCell"
        static let endGameButtonTitle: String = "Покинуть игру"
        static let endGameButtonMultiplier: CGFloat = 0.5
        static let endGameButtonHeight: CGFloat = 40
    }

    // MARK: - Private properties

    private let interactor: GameInteractor
    private let playerManager: PlayerManagerProtocol
    private let propertyManager: PropertyManagerProtocol
    private let logManager: LogManagerProtocol
    private let positionService: PositioningServiceProtocol

    private var tradingIsActive = false {
        didSet { updateAlertVisibility() }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(PlayerCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        return collectionView
    }()

    private lazy var boardView: BoardView = {
        let boardView = BoardView()
        boardView.translatesAutoresizingMaskIntoConstraints = false
        boardView.backgroundColor = .clear
        boardView.delegate = self
        boardView.clipsToBounds = true
        boardView.layer.cornerRadius = Constants.cornerRadius
        return boardView
    }()

    private lazy var tradingView: TradeView = {
        let tradingView = TradeView()
        tradingView.translatesAutoresizingMaskIntoConstraints = false
        tradingView.delegate = self
        return tradingView
    }()

    private lazy var logTableView: LogTableView = {
        let log = LogTableView()
        log.translatesAutoresizingMaskIntoConstraints = false
        return log
    }()

    private lazy var exitButton = ActionButton(style: .negative, title: Constants.endGameButtonTitle)
    private lazy var dataSource = PlayerCollectionViewDataSource(playerManager: playerManager)

    // MARK: - Lifecycle

    init(
        interactor: GameInteractor,
        playerManager: PlayerManagerProtocol,
        propertyManager: PropertyManagerProtocol,
        logManager: LogManagerProtocol,
        positionService: PositioningServiceProtocol
    ) {
        self.interactor = interactor
        self.playerManager = playerManager
        self.propertyManager = propertyManager
        self.logManager = logManager
        self.positionService = positionService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
            super.viewDidLoad()
            setupSubviews()
            configureCollectionView()
            setupConstraints()
            interactor.handleRequest(.startGame)
        }

    // MARK: - Private methods

    private func setupSubviews() {
            view.backgroundColor = .black
            navigationController?.navigationBar.isHidden = true
            view.addSubviews(boardView, logTableView, collectionView)
        }

    private func configureCollectionView() {
           collectionView.dataSource = dataSource
           collectionView.delegate = dataSource
           dataSource.didSelectPlayer = { [weak self] index, cell in
               guard let self = self else { return }
               interactor.handleRequest(.didSelectPlayer(index: index, sourceView: cell))
           }
       }

    private func updateAlertVisibility() {
        view.subviews.compactMap { $0 as? AlertView }.forEach { alertView in
            alertView.isHidden = tradingIsActive
            alertView.isUserInteractionEnabled = !tradingIsActive
        }
    }

    private func setupConstraints() {
        let boardSize = view.bounds.width - Constants.defaultPaddings
        let widthForSqare = (boardSize / Constants.maxCards) * Constants.numberOfCardsInSqare
        let sizeForBoard = boardSize - (widthForSqare * Constants.numberOfCardsInSqare)

        NSLayoutConstraint.activate([

            boardView.widthAnchor.constraint(equalToConstant: view.bounds.width - Constants.defaultPaddings),
            boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor),
            boardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            boardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            logTableView.widthAnchor.constraint(equalToConstant: sizeForBoard),
            logTableView.heightAnchor.constraint(equalToConstant: sizeForBoard),
            logTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logTableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            collectionView.bottomAnchor.constraint(greaterThanOrEqualTo: boardView.topAnchor, constant: -Constants.defaultPaddings),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.defaultPaddings),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.defaultPaddings),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.defaultPaddings),
        ])

        let minSpacing: CGFloat = Constants.collectionMinSpacing
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: Constants.collectionMaxHeight)
        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([heightConstraint])

        let spacingConstraint = collectionView.bottomAnchor.constraint(lessThanOrEqualTo: boardView.topAnchor, constant: -minSpacing)
        spacingConstraint.priority = .required

        NSLayoutConstraint.activate([spacingConstraint])

        boardView.boardSize = boardSize
    }

    private func addPropertyToTrade(_ property: Property) {
        guard property.cardType == .streets, property.owner != nil,
              propertyManager.shouldAddToOffer(selectedProperty: property)
        else { return }

        tradingView.addProperty(property)
    }

    private func createAlertView(twoButtons: Bool, model: AlertModel) {
        DispatchQueue.main.async { [self] in
            let alertView = AlertView()
            alertView.translatesAutoresizingMaskIntoConstraints = false
            alertView.layer.cornerRadius = Constants.cornerRadius
            view.addSubview(alertView)
            alertView.delegate = self

            if !twoButtons {
                alertView.configureWithOneButton(model: model)
            } else {
                alertView.configureWithTwoButton(model: model)
            }

            NSLayoutConstraint.activate([
                alertView.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: Constants.alertViewTop),
                alertView.leadingAnchor.constraint(equalTo: boardView.leadingAnchor),
                alertView.trailingAnchor.constraint(equalTo: boardView.trailingAnchor),
                alertView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.alertMaxHeight),
                alertView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.defaultPaddings)
            ])
        }
    }
}

// MARK: - GameView

extension GameViewController: GameView {

    func removeAlerts() {
        self.closeView()
    }

    func playerSurrender(_ id: String) {
        guard let subview = boardView.subviews.first(where: { $0.accessibilityIdentifier == id }) else { return }
        subview.removeFromSuperview()

        if playerManager.getCurrentUserId() == id {
            exitButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(exitButton)

            NSLayoutConstraint.activate([
                exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.defaultPaddings),
                exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                exitButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.endGameButtonMultiplier),
                exitButton.heightAnchor.constraint(equalToConstant: Constants.endGameButtonHeight)
            ])

            exitButton.addAction(
                UIAction { [weak self] _ in
                    self?.interactor.handleRequest(.exitGame)
                },
                for: .touchUpInside
            )
        }
    }

    func updatePayButtonInAlert(amount: Int) {
        let currentPlayer = playerManager.getCurrentPlayer()
        if currentPlayer.money >= amount {
            view.subviews.compactMap { $0 as? AlertView }.forEach { alertView in
                    alertView.updatePayButtonInAlert()
            }
        }
    }

    func updatePlayersInformation() {
        collectionView.reloadData()
        let currentPlayer = playerManager.getCurrentPlayer()
        updatePayButtonInAlert(amount: currentPlayer.amountDebt)

    }

    func updateAllProperties() {
        let properties = propertyManager.getAllProperties()
        boardView.updateAllProperties(properties: properties)
    }

    func startGame() {
        positionService.setupPlayers(boardView: boardView)
        let properties = propertyManager.getAllProperties()
        boardView.configureViews(properties: properties)
    }

    func logOnBoard(message: String) {
        logManager.addLog(message)
        logTableView.update(with: logManager.logs)
    }

    func movePlayerToPosition(position: Int) {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            guard let self else { return }
            positionService.positionPlayers(at: position, boardView: boardView)
        }
    }

    func moveOneStep(stepsRemaining: Int, position: Int, isLastStep: Bool) {
        positionService.moveOneStep(
            stepsRemaining: stepsRemaining,
            position: position,
            isLastStep: isLastStep,
            boardView: boardView
        ) { [weak self] in
            self?.interactor.handleRequest(.animateMovement(stepsRemaining: stepsRemaining))
        }
    }

    func showAlert(model: AlertModel, twoButtons: Bool) {
        createAlertView(twoButtons: twoButtons, model: model)
    }

    func showTradingView(currentPlayer: Player, tradingPlayer: Player) {
        guard !tradingIsActive else { return }

        view.addSubview(tradingView)

        NSLayoutConstraint.activate([
            tradingView.widthAnchor.constraint(equalToConstant: logTableView.frame.width),
            tradingView.heightAnchor.constraint(equalToConstant: logTableView.frame.height),
            tradingView.centerXAnchor.constraint(equalTo: boardView.centerXAnchor),
            tradingView.centerYAnchor.constraint(equalTo: boardView.centerYAnchor),
        ])

        tradingView.configure(from: currentPlayer, to: tradingPlayer)
        tradingIsActive = true
    }
}

// MARK: - BoardViewDelegate

extension GameViewController: BoardViewDelegate {

    func didSelectProperty(property: Property, view: UIView) {
        if tradingIsActive {
            self.addPropertyToTrade(property)
        } else {
            if playerManager.getCurrentPlayer().id == playerManager.getCurrentUserId() {
                interactor.handleRequest(.didSelectProperty(property: property, sourceView: view))
            }
        }
    }
}

// MARK: - TradeViewDelegate

extension GameViewController: TradeViewDelegate {

    func proposeTrade(_ model: TradeViewModel) {
        interactor.handleRequest(.proposeTrade(model))
        closeTradeView()
    }

    func closeTradeView() {
        tradingView.removeFromSuperview()
        tradingView.clear()
        tradingIsActive = false
    }
}

// MARK: - AlertViewDelegate

extension GameViewController: AlertViewDelegate {

    func closeView() {
        view.subviews.compactMap { $0 as? AlertView }.forEach { $0.removeFromSuperview() }
    }
}
