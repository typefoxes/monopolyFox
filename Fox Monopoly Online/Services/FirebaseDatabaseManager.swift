//
//  FirebaseDatabaseManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 18.02.2025.
//

import Foundation
import FirebaseDatabase

final class FirebaseDatabaseManager: FirebaseDatabaseManagerProtocol {

    // MARK: - Properties

    private let database = Database.database().reference()
    private let gameID: String
    private var observers = [UInt]()

    // MARK: - Lifecycle

    init(gameID: String = String.empty) {
        self.gameID = gameID
    }

    deinit {
        observers.forEach { database.removeObserver(withHandle: $0) }
    }

    // MARK: - Observers

    func observePlayerMovements(completion: @escaping (Result<(String, Int), FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("players")
        let handle = ref.observe(.childChanged) { snapshot in
            let playerID = snapshot.key
            guard let position = snapshot.childSnapshot(forPath: "position").value as? Int else {
                completion(.failure(.invalidData(message: "Позиция игрока не найдена")))
                return
            }
            completion(.success((playerID, position)))
        }

        observers.append(handle)
    }

    func observePlayerMoveToBack(completion: @escaping (Result<(String, Bool), FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("players")
        let handle = ref.observe(.childChanged) { snapshot in
            let playerID = snapshot.key
            guard let isMoveBack = snapshot.childSnapshot(forPath: "isMoveBack").value as? Bool else {
                completion(.failure(.invalidData(message: "Флаг перемещения назад не найден")))
                return
            }
            completion(.success((playerID, isMoveBack)))
        }
        observers.append(handle)
    }

    func observePropertyOwner(completion: @escaping (Result<(Int, String?), FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("properties")
        let addedHandle = ref.observe(.childAdded) { snapshot in
            self.handlePropertySnapshot(snapshot, completion: completion)
        }
        let changedHandle = ref.observe(.childChanged) { snapshot in
            self.handlePropertySnapshot(snapshot, completion: completion)
        }
        observers.append(contentsOf: [addedHandle, changedHandle])
    }

    private func handlePropertySnapshot(_ snapshot: DataSnapshot, completion: @escaping (Result<(Int, String?), FirebaseDatabaseManagerError>) -> Void) {
        guard let propertyId = Int(snapshot.key) else {
            completion(.failure(.invalidPropertyData))
            return
        }
        let ownerId = snapshot.childSnapshot(forPath: "ownerId").value as? String
        completion(.success((propertyId, ownerId)))
    }

    func observePropertyRedeem(completion: @escaping (Result<Int, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("properties").child("redeem")
        let handle = ref.observe(.childChanged) { snapshot in
            guard let propertyId = Int(snapshot.key) else {
                completion(.failure(.invalidPropertyData))
                return
            }
            completion(.success(propertyId))
        }
        observers.append(handle)
    }

    func observePropertyMortgage(completion: @escaping (Result<Int, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("properties").child("mortgage")
        let handle = ref.observe(.childChanged) { snapshot in
            guard let propertyId = Int(snapshot.key) else {
                completion(.failure(.invalidPropertyData))
                return
            }
            completion(.success(propertyId))
        }
        observers.append(handle)
    }

    func observePropertyHotels(completion: @escaping (Result<HotelsData, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("hotels")
        let handle = ref.observe(.value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value as? [String: Any] else {
                completion(.failure(.snapshotNotFound(message: "observePropertyHotels")))
                return
            }

            switch self.parseHotelsData(data) {
            case .success(let hotelsData):
                completion(.success(hotelsData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        observers.append(handle)
    }

    func observePlayerMoney(completion: @escaping (Result<(String, Int), FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("players")
        let handle = ref.observe(.childChanged) { snapshot in
            let playerID = snapshot.key
            guard let money = snapshot.childSnapshot(forPath: "money").value as? Int else {
                completion(.failure(.invalidData(message: "Данные о деньгах игрока не найдены")))
                return
            }
            completion(.success((playerID, money)))
        }
        observers.append(handle)
    }

    func observePlayerInJail(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("jailTrigger")
        let handle = ref.observe(.value) { snapshot in
            guard let playerID = snapshot.value as? String else {
                completion(.failure(.invalidData(message: "Данные об игроке в тюрьме не найдены")))
                return
            }
            completion(.success(playerID))
        }
        observers.append(handle)
    }

    func observePlayerJailAttempts(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("jailAttempts")
        let handle = ref.observe(.value) { snapshot in
            guard let playerID = snapshot.value as? String else {
                completion(.failure(.invalidData(message: "Данные о попытках выхода из тюрьмы не найдены")))
                return
            }
            completion(.success(playerID))
        }
        observers.append(handle)
    }

    func observeEndGame(completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("endGame")
        let handle = ref.observe(.value) { snapshot in
            guard snapshot.exists() else {
                completion(.failure(.snapshotNotFound(message: "observeEndGame")))
                return
            }
            completion(.success(()))
        }
        observers.append(handle)
    }

    func observePlayerReleasePlayerFromJail(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("releasePlayerFromJail")
        let handle = ref.observe(.value) { snapshot in
            guard let playerID = snapshot.value as? String else {
                completion(.failure(.invalidData(message: "Данные об освобождении из тюрьмы не найдены")))
                return
            }
            completion(.success(playerID))
        }
        observers.append(handle)
    }

    func observeCurrentPlayer(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("currentPlayer")
        let handle = ref.observe(.value) { snapshot in
            guard let playerID = snapshot.value as? String else {
                completion(.failure(.invalidData(message: "Данные о текущем игроке не найдены")))
                return
            }
            completion(.success(playerID))
        }
        observers.append(handle)
    }

    func observeSurrenderPlayer(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("playerSurrender")
        let handle = ref.observe(.value) { snapshot in
            guard let playerID = snapshot.value as? String else {
                completion(.failure(.invalidData(message: "Данные о сдаче игрока не найдены")))
                return
            }
            completion(.success(playerID))
        }
        observers.append(handle)
    }

    func observeLog(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("log")
        let handle = ref.observe(.value) { snapshot in
            guard let message = snapshot.value as? String else {
                completion(.failure(.invalidData(message: "Данные лога не найдены")))
                return
            }
            completion(.success(message))
        }
        observers.append(handle)
    }

    func observeAuction(completion: @escaping (Result<AuctionData, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("auction")
        let handle = ref.observe(.value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value as? [String: Any] else {
                completion(.failure(.snapshotNotFound(message: "observeAuction")))
                return
            }

            switch self.parseAuctionData(data) {
            case .success(let auctionData):
                completion(.success(auctionData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        observers.append(handle)
    }

    func observeTradeProposal(completion: @escaping (Result<TradeProposal, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("proposeTrade")
        let handle = ref.observe(.value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value as? [String: Any] else {
                completion(.failure(.snapshotNotFound(message: "observeTradeProposal")))
                return
            }

            switch self.parseTradeData(data) {
            case .success(let proposal):
                completion(.success(proposal))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        observers.append(handle)
    }

    func observePlayers(gameID: String, completion: @escaping (Result<[PlayerData], FirebaseDatabaseManagerError>) -> Void) -> UInt {
        let ref = database.child("games").child(gameID).child("players")
        let handle = ref.observe(.value) { snapshot in
            var players = [PlayerData]()
            for child in snapshot.children {
                guard let snap = child as? DataSnapshot,
                      let name = snap.value as? String else {
                    completion(.failure(.invalidPlayerData))
                    return
                }
                players.append(PlayerData(uid: snap.key, name: name))
            }
            completion(.success(players))
        }
        observers.append(handle)
        return handle
    }

    func observeGameStatus(gameID: String, completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void) -> UInt {
        let ref = database.child("games").child(gameID).child("status")
        let handle = ref.observe(.value) { snapshot in
            guard let status = snapshot.value as? String else {
                completion(.failure(.invalidData(message: "Статус игры не найден")))
                return
            }
            completion(.success(status))
        }
        return handle
    }

    // MARK: - Update Methods

    func proposeTrade(model: TradeViewModel, completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        var fromPlayerProperties = [Int]()
        var toPlayerProperties = [Int]()

        if let data = model.fromPlayerProperties {
            fromPlayerProperties = data.map { $0.position }
        }

        if let data = model.toPlayerProperties {
            toPlayerProperties = data.map { $0.position }
        }

        let proposalDict: [String: Any] = [
            "fromPlayer": model.fromPlayer.id,
            "toPlayer": model.toPlayer.id,
            "fromPlayerProperties": fromPlayerProperties,
            "toPlayerProperties": toPlayerProperties,
            "fromPlayerMoney": model.fromPlayerMoney,
            "toPlayerMoney": model.toPlayerMoney
        ]

        database.child("games").child(gameID).child("proposeTrade").setValue(proposalDict) { error, _ in
            if let error = error {
                completion(.failure(.networkError(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    func updateAuctionData(auctionData: [String: Any], completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        database.child("games").child(gameID).child("auction").setValue(auctionData) { error, _ in
            if let error = error {
                completion(.failure(.networkError(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    func updatePlayerPosition(playerID: String, position: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("players").child(playerID).child("position")
        ref.setValue(position) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePlayerMoveToBack(playerID: String, isMoveBack: Bool, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("players").child(playerID).child("isMoveBack")
        ref.setValue(isMoveBack) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePlayerMoney(playerID: String, money: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("players").child(playerID).child("money")
        ref.setValue(money) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePropertyOwner(propertyId: Int, ownerId: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("properties").child("\(propertyId)").child("ownerId")
        ref.setValue(ownerId) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePropertyRedeem(propertyId: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("properties").child("redeem").child("\(propertyId)")
        ref.setValue(ServerValue.timestamp()) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePropertyMortgage(propertyId: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        let ref = database.child("games").child(gameID).child("properties").child("mortgage").child("\(propertyId)")
        ref.setValue(ServerValue.timestamp()) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePropertyHotels(propertyId: Int, hotels: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        let dataDict: [String: Any] = [
            "propertyId": propertyId,
            "count": hotels
        ]

        database.child("games").child(gameID).child("hotels").setValue(dataDict) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePlayerInJail(_ id: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        database.child("games").child(gameID).child("jailTrigger").setValue(id) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updateEndGame(_ id: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        database.child("games").child(gameID).child("endGame").setValue(id) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePlayerJailAttempts(_ id: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        database.child("games").child(gameID).child("jailAttempts").setValue(id) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePlayerReleasePlayerFromJail(_ id: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        database.child("games").child(gameID).child("releasePlayerFromJail").setValue(id) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updateCurrentPlayer(nextPlayerId: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        database.child("games").child(gameID).child("currentPlayer").setValue(nextPlayerId) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updatePlayerSurrender(playerId: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        database.child("games").child(gameID).child("playerSurrender").setValue(playerId) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updateLog(message: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)? = nil) {
        guard !gameID.isEmpty else {
            completion?(.failure(.invalidGameID))
            return
        }

        database.child("games").child(gameID).child("log").setValue(message) { error, _ in
            if let error = error {
                completion?(.failure(.networkError(error)))
            } else {
                completion?(.success(()))
            }
        }
    }

    func updateAuction(_ auctionData: AuctionData, completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void) {
        guard !gameID.isEmpty else {
            completion(.failure(.invalidGameID))
            return
        }

        let auctionDict: [String: Any] = [
            "propertyPosition": auctionData.propertyPosition,
            "propertyPrice": auctionData.propertyPrice,
            "currentBid": auctionData.currentBid,
            "auctionPlayers": auctionData.auctionPlayers,
            "currentBidderIndex": auctionData.currentBidderIndex as Any
        ]

        database.child("games").child(gameID).child("auction").setValue(auctionDict) { error, _ in
            if let error = error {
                completion(.failure(.networkError(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    func createGame(
        gameID: String,
        userID: String,
        displayName: String?,
        completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void
    ) {
        let gameData: [String: Any] = [
            "host": userID,
            "players": [userID: displayName ?? "Unknown"],
            "status": "waiting"
        ]

        database.child("games").child(gameID).setValue(gameData) { error, _ in
            if let error = error {
                completion(.failure(.networkError(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    func joinGame(
        gameID: String,
        userID: String,
        displayName: String?,
        completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void
    ) {
        database.child("games").child(gameID).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard snapshot.exists() else {
                completion(.failure(.gameNotFound))
                return
            }

            self?.database.child("games").child(gameID).child("players").child(userID).setValue(displayName) { error, _ in
                    if let error = error {
                        completion(.failure(.networkError(error)))
                    } else {
                        completion(.success(()))
                    }
                }
        }
    }

    func updateGameStatus(gameID: String, status: String, completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void) {
        database.child("games").child(gameID).child("status").setValue(status) { error, _ in
            if let error = error {
                completion(.failure(.networkError(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    func getHostId(gameID: String, completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void) {
        database.child("games").child(gameID).child("host").observeSingleEvent(of: .value) { snapshot in
            guard let hostId = snapshot.value as? String else {
                completion(.failure(.invalidData(message: "ID создателя игры не найден")))
                return
            }
            completion(.success(hostId))
        }
    }

    func removeObserver(with handle: UInt) {
        database.removeObserver(withHandle: handle)
        observers.removeAll { $0 == handle }
    }

    func leaveGame(gameID: String, userID: String, completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void) {
        database.child("games").child(gameID).child("players").child(userID).removeValue { error, _ in
            if let error = error {
                completion(.failure(.networkError(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    private func parseAuctionData(_ data: [String: Any]) -> Result<AuctionData, FirebaseDatabaseManagerError> {
        guard let propertyPosition = data["propertyPosition"] as? Int,
              let propertyPrice = data["propertyPrice"] as? Int,
              let currentBid = data["currentBid"] as? Int,
              let auctionPlayers = data["auctionPlayers"] as? [String] else {
            return .failure(.invalidAuctionData)
        }
        let currentBidderIndex = data["currentBidderIndex"] as? Int

        return .success(AuctionData(
            propertyPosition: propertyPosition,
            propertyPrice: propertyPrice,
            currentBid: currentBid,
            auctionPlayers: auctionPlayers,
            currentBidderIndex: currentBidderIndex
        ))
    }

    private func parseTradeData(_ data: [String: Any]) -> Result<TradeProposal, FirebaseDatabaseManagerError> {
        guard let fromPlayer = data["fromPlayer"] as? String,
              let toPlayer = data["toPlayer"] as? String,
              let fromPlayerMoney = data["fromPlayerMoney"] as? Int,
              let toPlayerMoney = data["toPlayerMoney"] as? Int else {
            return .failure(.invalidTradeData)
        }

        let fromPlayerProperties = data["fromPlayerProperties"] as? [Int]
        let toPlayerProperties = data["toPlayerProperties"] as? [Int]

        return .success(TradeProposal(
            fromPlayer: fromPlayer,
            toPlayer: toPlayer,
            fromPlayerProperties: fromPlayerProperties,
            toPlayerProperties: toPlayerProperties,
            fromPlayerMoney: fromPlayerMoney,
            toPlayerMoney: toPlayerMoney
        ))
    }

    private func parseHotelsData(_ data: [String: Any]) -> Result<HotelsData, FirebaseDatabaseManagerError> {
        guard let propertyId = data["propertyId"] as? Int,
              let count = data["count"] as? Int else {
            return .failure(.invalidHotelData)
        }
        return .success(HotelsData(propertyId: propertyId, count: count))
    }
}
