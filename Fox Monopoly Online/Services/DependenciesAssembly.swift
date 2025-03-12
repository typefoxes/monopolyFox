//
//  DependenciesAssembly.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 04.03.2025.
//

protocol DependenciesAssemblyProtocol {
    /// Менеджер аукциона
    var auctionManager: AuctionManagerProtocol { get }
    /// Менеджер пользовательских уведомлений
    var alertManager: AlertManagerProtocol { get }
    /// Менеджер платежей
    var paymentManager: PaymentManagerProtocol { get }
    /// Менеджер клеток игрового поля
    var fieldManager: FieldManagerProtocol { get }
    /// Менеджер движений игрока
    var movementManager: MovementManagerProtocol { get }
    /// Менеджер firebase базы
    var databaseManager: FirebaseDatabaseManagerProtocol { get }
    /// Менеджер карточек шанс
    var chanceManager: ChanceManagerProtocol { get }
    /// Менеджер кубиков
    var diceService: DiceServiceProtocol { get }
    /// Менеджер игроков
    var playerManager: PlayerManagerProtocol { get }
    /// Менеджер собственности
    var propertyManager: PropertyManagerProtocol { get }
    /// Менеджер торгов
    var tradeManager: TradeManagerProtocol { get }
    /// Менеджер авторизации
    var authManager: AuthManagerProtocol { get }
    /// Менеджер логирования
    var logManager: LogManagerProtocol { get }
    /// Сервис для настройки игрового поля и анимаций
    var positioningService: PositioningServiceProtocol { get }
}

final class DependenciesAssembly: DependenciesAssemblyProtocol {

    // MARK: - Private properties

    private var gameId: String?

    // MARK: - Lifecycle

    init(gameId: String? = nil) {
        self.gameId = gameId
    }

    // MARK: - DependenciesAssemblyProtocol

    lazy var logManager: any LogManagerProtocol = {
        LogManager()
    }()

    lazy var authManager: any AuthManagerProtocol = {
        AuthManager()
    }()

    lazy var databaseManager: any FirebaseDatabaseManagerProtocol = {
        FirebaseDatabaseManager(gameID: gameId ?? String.empty)
    }()

    lazy var playerManager: any PlayerManagerProtocol = {
        PlayerManager(currentUserId: authManager.currentUser()?.uid ?? String.empty)
    }()

    lazy var positioningService: any PositioningServiceProtocol = {
        PositioningService(playerManager: playerManager)
    }()

    lazy var diceService: any DiceServiceProtocol = {
        DiceService()
    }()

    lazy var tradeManager: any TradeManagerProtocol = {
        TradeManager(databaseManager: databaseManager, playerManager: playerManager)
    }()

    lazy var propertyManager: any PropertyManagerProtocol = {
        PropertyManager()
    }()

    lazy var alertManager: any AlertManagerProtocol = {
        AlertManager(
            playerManager: playerManager,
            databaseManager: databaseManager
        )
    }()

    lazy var paymentManager: any PaymentManagerProtocol = {
        PaymentManager(
            diceService: diceService,
            propertyManager: propertyManager,
            databaseManager: databaseManager,
            playerManager: playerManager,
            alertManager: alertManager
        )
    }()

    lazy var auctionManager: any AuctionManagerProtocol = {
        AuctionManager(
            playerManager: playerManager,
            databaseManager: databaseManager,
            paymentManager: paymentManager,
            alertManager: alertManager,
            propertyManager: propertyManager
        )
    }()

    lazy var fieldManager: any FieldManagerProtocol = {
        FieldManager(
            playerManager: playerManager,
            databaseManager: databaseManager,
            paymentManager: paymentManager,
            alertManager: alertManager,
            auctionManager: auctionManager,
            chanceManager: chanceManager
        )
    }()

    lazy var movementManager: any MovementManagerProtocol = {
        MovementManager(
            diceService: diceService,
            databaseManager: databaseManager,
            playerManager: playerManager,
            fieldManager: fieldManager,
            propertyManager: propertyManager,
            alertManager: alertManager
        )
    }()

    lazy var chanceManager: any ChanceManagerProtocol = {
        ChanceManager(
            databaseManager: databaseManager,
            propertyManager: propertyManager,
            playerManager: playerManager,
            alertManager: alertManager,
            paymentManager: paymentManager
        )
    }()
}
