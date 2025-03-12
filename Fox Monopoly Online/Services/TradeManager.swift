//
//  Untitled.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 01.03.2025.
//
protocol TradeManagerProtocol {
    /// Обновить доску после торгов
    /// - Parameter model: модель торгов
    func updateAfterTrade(_ model: TradeViewModel)
}

final class TradeManager: TradeManagerProtocol {

    // MARK: - Constants

    private enum Constants {
        static let tradeEnded = "🎉 Сделка завершена между %@ и %@!"
    }

    // MARK: - Private properties

    private let databaseManager: FirebaseDatabaseManagerProtocol
    private let playerManager: PlayerManagerProtocol

    // MARK: - Lifecycle

    init(databaseManager: FirebaseDatabaseManagerProtocol, playerManager: PlayerManagerProtocol) {
        self.databaseManager = databaseManager
        self.playerManager = playerManager
    }

    // MARK: - TradeManagerProtocol

    func updateAfterTrade(_ model: TradeViewModel) {
        if let data = model.fromPlayerProperties {
            for property in data {
                databaseManager.updatePropertyOwner(propertyId: property.position, ownerId: model.toPlayer.id) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
            }
        }

        if let data = model.toPlayerProperties {
            for property in data {
                databaseManager.updatePropertyOwner(propertyId: property.position, ownerId: model.fromPlayer.id) { [weak self] result in
                    self?.handleDatabaseResult(result)
                }
            }
        }

        if let toPlayerMoney = playerManager.findPlayer(id: model.toPlayer.id)?.money {
            self.databaseManager.updatePlayerMoney(playerID: model.toPlayer.id, money: toPlayerMoney - model.toPlayerMoney + model.fromPlayerMoney) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
        }
        if let fromPlayerMoney = playerManager.findPlayer(id: model.fromPlayer.id)?.money {
            databaseManager.updatePlayerMoney(playerID: model.fromPlayer.id, money: fromPlayerMoney - model.fromPlayerMoney + model.toPlayerMoney) { [weak self] result in
                self?.handleDatabaseResult(result)
            }
        }
        databaseManager.updateLog(message: String(format: Constants.tradeEnded, model.fromPlayer.name, model.toPlayer.name)) { [weak self] result in
            self?.handleDatabaseResult(result)
        }
    }

    // MARK: - Private methods

    private func handleDatabaseResult<T>(_ result: Result<T, FirebaseDatabaseManagerError>) {
        switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
            case .success:
                break
        }
    }
}
