//
//  FirebaseDatabaseManagerProtocol.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 11.03.2025.
//

protocol FirebaseDatabaseManagerProtocol {

    // MARK: - Методы экрана игры

    /// Начинает наблюдение за перемещениями игроков на поле
    /// - Parameter completion: Блок, вызываемый при изменении позиции игрока. Принимает ID игрока (String) и новую позицию (Int)
    func observePlayerMovements(completion: @escaping (Result<(String, Int), FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за флагом обратного движения игроков
    /// - Parameter completion: Блок, вызываемый при изменении направления. Принимает ID игрока (String) и флаг движения назад (Bool)
    func observePlayerMoveToBack(completion: @escaping (Result<(String, Bool), FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за изменением владельцев собственностей
    /// - Parameter completion: Блок, вызываемый при смене владельца. Принимает ID свойства (Int) и ID нового владельца (String? - nil если нет владельца)
    func observePropertyOwner(completion: @escaping (Result<(Int, String?), FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за изменением количества денег игроков
    /// - Parameter completion: Блок, вызываемый при изменении баланса. Принимает ID игрока (String) и новую сумму (Int)
    func observePlayerMoney(completion: @escaping (Result<(String, Int), FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за отправкой игроков в тюрьму
    /// - Parameter completion: Блок, вызываемый при изменении статуса. Принимает ID игрока (String)
    func observePlayerInJail(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за количеством попыток выхода из тюрьмы
    /// - Parameter completion: Блок, вызываемый при изменении количества попыток. Принимает ID игрока (String)
    func observePlayerJailAttempts(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за освобождением игроков из тюрьмы
    /// - Parameter completion: Блок, вызываемый при освобождении. Принимает ID игрока (String)
    func observePlayerReleasePlayerFromJail(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за сменой текущего активного игрока
    /// - Parameter completion: Блок, вызываемый при смене игрока. Принимает ID нового активного игрока (String)
    func observeCurrentPlayer(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за игровым логом
    /// - Parameter completion: Блок, вызываемый при новой записи в логе. Принимает сообщение (String)
    func observeLog(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за аукционом
    /// - Parameter completion: Блок, вызываемый при изменении данных аукциона. Принимает AuctionData или nil при завершении аукциона
    func observeAuction(completion: @escaping (Result<AuctionData, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за выкупом собственности
    /// - Parameter completion: Блок, вызываемый при выкупе. Принимает ID выкупаемой собственности (Int)
    func observePropertyRedeem(completion: @escaping (Result<Int, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за залогом собственности
    /// - Parameter completion: Блок, вызываемый при залоге. Принимает ID закладываемой собственности (Int)
    func observePropertyMortgage(completion: @escaping (Result<Int, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за изменением количества отелей
    /// - Parameter completion: Блок, вызываемый при изменении. Принимает ID собственности (Int) и новое количество отелей (Int?)
    func observePropertyHotels(completion: @escaping (Result<HotelsData, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за предложениями обмена
    /// - Parameter completion: Блок, вызываемый при новом предложении. Принимает TradeProposal или nil при отмене
    func observeTradeProposal(completion: @escaping (Result<TradeProposal, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за выходом игроков
    /// - Parameter completion: Блок, вызываемый при выходе. Принимает ID сдавшегося игрока (String)
    func observeSurrenderPlayer(completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void)
    /// Начинает наблюдение за завершением игры
    /// - Parameter completion: Блок, вызываемый при завершении игры
    func observeEndGame(completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void)
    /// Обновляет данные аукциона
    /// - Parameter auctionData: Словарь с данными аукциона
    func updateAuctionData(auctionData: [String: Any], completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void)
    /// Обновляет позицию игрока на поле
    /// - Parameters:
    ///   - playerID: ID игрока
    ///   - position: Новая позиция
    func updatePlayerPosition(playerID: String, position: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Обновляет флаг обратного движения для игрока
    /// - Parameters:
    ///   - playerID: ID игрока
    ///   - isMoveBack: Новое значение флага
    func updatePlayerMoveToBack(playerID: String, isMoveBack: Bool, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Обновляет количество денег игрока
    /// - Parameters:
    ///   - playerID: ID игрока
    ///   - money: Новая сумма
    func updatePlayerMoney(playerID: String, money: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Обновляет владельца собственности
    /// - Parameters:
    ///   - propertyId: ID собственности
    ///   - ownerId: ID нового владельца
    func updatePropertyOwner(propertyId: Int, ownerId: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Отправляет игрока в тюрьму
    /// - Parameter id: ID игрока
    func updatePlayerInJail(_ id: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Обновляет количество попыток выхода из тюрьмы
    /// - Parameter id: ID игрока
    func updatePlayerJailAttempts(_ id: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Освобождает игрока из тюрьмы
    /// - Parameter id: ID игрока
    func updatePlayerReleasePlayerFromJail(_ id: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Меняет текущего активного игрока
    /// - Parameter nextPlayerId: ID следующего игрока
    func updateCurrentPlayer(nextPlayerId: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Добавляет запись в игровой лог
    /// - Parameter message: Текст сообщения
    func updateLog(message: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Обновляет данные аукциона
    /// - Parameter auctionData: Модель данных аукциона
    func updateAuction(_ auctionData: AuctionData, completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void)
    /// Помечает собственность как выкупленную
    /// - Parameter propertyId: ID собственности
    func updatePropertyRedeem(propertyId: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Помечает собственность как заложенную
    /// - Parameter propertyId: ID собственности
    func updatePropertyMortgage(propertyId: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Обновляет количество отелей на собственности
    /// - Parameters:
    ///   - propertyId: ID собственности
    ///   - hotels: Новое количество отелей
    func updatePropertyHotels(propertyId: Int, hotels: Int, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Отправляет предложение обмена
    /// - Parameter model: Модель данных обмена
    func proposeTrade(model: TradeViewModel, completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void)
    /// Помечает игрока как сдавшегося
    /// - Parameter playerId: ID игрока
    func updatePlayerSurrender(playerId: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)
    /// Инициирует завершение игры
    /// - Parameter id: ID победителя
    func updateEndGame(_ id: String, completion: ((Result<Void, FirebaseDatabaseManagerError>) -> Void)?)

    // MARK: - Методы экрана лобби

    /// Создает новую игру
    /// - Parameters:
    ///   - gameID: Уникальный идентификатор игры
    ///   - userID: ID пользователя-создателя
    ///   - displayName: Отображаемое имя (опционально)
    ///   - completion: Блок с результатом операции
    func createGame(
        gameID: String,
        userID: String,
        displayName: String?,
        completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void
    )
    /// Присоединяет игрока к существующей игре
    /// - Parameters:
    ///   - gameID: ID игры
    ///   - userID: ID пользователя
    ///   - displayName: Отображаемое имя (опционально)
    ///   - completion: Блок с результатом операции
    func joinGame(
        gameID: String,
        userID: String,
        displayName: String?,
        completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void
    )

    // MARK: - Методы экрана ожидания

    /// Начинает наблюдение за статусом игры
    /// - Parameters:
    ///   - gameID: ID игры
    ///   - completion: Блок с новым статусом игры
    /// - Returns: Хэндлер для отмены наблюдения
    func observeGameStatus(
        gameID: String,
        completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void
    ) -> UInt
    /// Начинает наблюдение за списком игроков
    /// - Parameters:
    ///   - gameID: ID игры
    ///   - completion: Блок с обновленным списком игроков
    /// - Returns: Хэндлер для отмены наблюдения
    func observePlayers(
        gameID: String,
        completion: @escaping (Result<[PlayerData], FirebaseDatabaseManagerError>) -> Void
    ) -> UInt
    /// Получает ID создателя игры
    /// - Parameters:
    ///   - gameID: ID игры
    ///   - completion: Блок с ID хоста или nil
    func getHostId(
        gameID: String,
        completion: @escaping (Result<String, FirebaseDatabaseManagerError>) -> Void
    )
    /// Удаляет наблюдатель по хэндлеру
    /// - Parameter handle: Хэндлер наблюдателя
    func removeObserver(with handle: UInt)
    /// Обновляет статус игры
    /// - Parameters:
    ///   - gameID: ID игры
    ///   - status: Новый статус
    func updateGameStatus(
        gameID: String,
        status: String,
        completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void
    )
    /// Покинуть игру
    /// - Parameters:
    ///   - gameID: ID игры
    ///   - userID: ID пользователя
    ///   - completion: Блок с результатом операции
    func leaveGame(
        gameID: String,
        userID: String,
        completion: @escaping (Result<Void, FirebaseDatabaseManagerError>) -> Void
    )
}
