//
//  AlertManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 01.03.2025.
//

import UIKit

protocol AlertManagerProtocol {
    /// Показывает диалоговое окно при возможности покупки поля
    /// - Parameters:
    ///   - property: Объект недвижимости для покупки
    ///   - buyCompletion: Замыкание при подтверждении покупки
    ///   - auctionCompletion: Замыкание для запуска аукциона
    func showBuyingAlert(
        property: Property,
        buyCompletion: @escaping () -> Void,
        auctionCompletion: @escaping () -> Void
    )
    /// Показывает диалоговое окно во время аукциона
    /// - Parameters:
    ///   - property: Объект  на аукционе
    ///   - player: Текущий игрок
    ///   - currentBid: Текущая ставка
    ///   - buyTitle: Текст кнопки покупки (nil - скрыть кнопку)
    ///   - completionOk: Замыкание при повышении ставки
    ///   - completion: Замыкание при отказе от ставки
    func showTurnAuctionAlert(
        property: Property,
        player: Player,
        currentBid: Int,
        buyTitle: String?,
        completionOk: @escaping () -> Void,
        completion: @escaping () -> Void
    )
    /// Показывает предупреждение о недостатке средств
    /// - Parameters:
    ///   - amount: Недостающая сумма
    ///   - payCompletion: Замыкание при попытке оплаты
    ///   - nextTernAction: Замыкание для перехода к следующему ходу
    func showNoMoneyAlert(
        amount: Int,
        payCompletion: @escaping () -> Void,
        nextTernAction: @escaping () -> Void?
    )
    /// Показывает уведомление о ходе игрока
    /// - Parameter rollCompletion: Замыкание для обработки броска кубиков
    func yourMoveAlert(rollCompletion: @escaping () -> Void)
    /// Показывает выбор действий в тюрьме
    /// - Parameters:
    ///   - payCompletion: Замыкание для оплаты выхода из тюрьмы
    ///   - rollCompletion: Замыкание для попытки выбросить дубль
    func askJailOptions(payCompletion: @escaping () -> Void, rollCompletion: @escaping () -> Void)
    /// Ссылка на игровое представление для обновления UI
    var delegate: GameView? { get set }
}

final class AlertManager: AlertManagerProtocol {

    // MARK: - Constants

    private struct Constants {
        struct Title {
            static let buying = "Покупаем?"
            static let auctionTemplate = "Аукцион: %@"
            static let insufficientFunds = "Недостаточно средств на оплату. Нужная сумма: %dk"
            static let yourMove = "Ваш ход"
            static let jailOptions = "Вaш ход! Вы находитесь в тюрьме."
        }

        struct Message {
            static let buying = "Если вы откажетесь от покупки, то поле будет выставлено на общий аукцион."
            static let auctionWithBuy = "Текущая ставка: %dk\n%@, хотите купить?"
            static let auctionRaise = "Текущая ставка: %dk\n%@, хотите поднять ставку?"
            static let insufficientFunds = "Вы можете попробовать продать свое имущество и заложить улицы"
            static let yourMove = "Счастливых Вам голодных игр. И пусть удача всегда будет с вами."
            static let jailOptions = "Но вы всё равно можете предлагать договоры."
        }

        struct Button {
            static let buyTemplate = "Купить за %dk"
            static let toAuction = "На аукцион"
            static let raiseBidTemplate = "Поднять ставку на %dk"
            static let refuse = "Отказаться"
            static let pay = "Оплатить"
            static let surrender = "Сдаться"
            static let rollDice = "🎲 Бросить кубики"
            static let bail = "Заплатить %dk"
        }

        struct Format {
            static let currencySuffix = "k"
        }

        struct Jail {
            static let bailAmount = 500
        }
    }

    // MARK: - Properties

    weak var delegate: GameView?
    private let playerManager: PlayerManagerProtocol
    private let databaseManager: FirebaseDatabaseManagerProtocol
    private var amountDepts: Int = .zero

    // MARK: - Lifecycle

    init(playerManager: PlayerManagerProtocol, databaseManager: FirebaseDatabaseManagerProtocol) {
        self.playerManager = playerManager
        self.databaseManager = databaseManager
    }

    // MARK: - AlertManagerProtocol

    func showBuyingAlert(property: Property, buyCompletion: @escaping () -> Void, auctionCompletion: @escaping () -> Void) {
        let model = AlertModel(
            title: Constants.Title.buying,
            message: Constants.Message.buying,
            leftButtonTitle: String(format: Constants.Button.buyTemplate, property.price),
            rightButtonTitle: Constants.Button.toAuction,
            actionLeftButton: buyCompletion,
            actionRightButton: auctionCompletion,
            leftButtonSelectable: true,
            rightButtonSelectable: true
        )

        delegate?.showAlert(model: model, twoButtons: true)
    }

    func showTurnAuctionAlert(property: Property, player: Player, currentBid: Int, buyTitle: String?, completionOk: @escaping () -> Void, completion: @escaping () -> Void) {
        let messageTemplate = buyTitle != nil ? Constants.Message.auctionWithBuy : Constants.Message.auctionRaise
        let message = String(format: messageTemplate, currentBid, player.name)

        let model = AlertModel(
            title: String(format: Constants.Title.auctionTemplate, property.name),
            message: message,
            leftButtonTitle: buyTitle ?? String(format: Constants.Button.raiseBidTemplate, 100),
            rightButtonTitle: Constants.Button.refuse,
            actionLeftButton: completionOk,
            actionRightButton: completion,
            leftButtonSelectable: true,
            rightButtonSelectable: true
        )

        delegate?.showAlert(model: model, twoButtons: true)
    }

    func showNoMoneyAlert(amount: Int, payCompletion: @escaping () -> Void, nextTernAction: @escaping () -> Void?) {
        let currentPlayer = playerManager.getCurrentPlayer()
        playerManager.updateAmountDebt(playerId: currentPlayer.id, amount: amount)

        let model = AlertModel(
            title: String(format: Constants.Title.insufficientFunds, amount),
            message: Constants.Message.insufficientFunds,
            leftButtonTitle: Constants.Button.pay,
            rightButtonTitle: Constants.Button.surrender,
            actionLeftButton: {
                payCompletion()
                self.amountDepts = .zero
            },
            actionRightButton: {
                self.databaseManager.updatePlayerSurrender(playerId: currentPlayer.id) { result in
                    switch result {
                        case .failure(let error):
                            debugPrint(error.localizedDescription)
                        case .success:
                            break
                    }
                }
                nextTernAction()
                self.amountDepts = .zero
            },
            leftButtonSelectable: false,
            rightButtonSelectable: true
        )

        amountDepts = amount
        delegate?.showAlert(model: model, twoButtons: true)
    }

    func yourMoveAlert(rollCompletion: @escaping () -> Void) {
        let model = AlertModel(
            title: Constants.Title.yourMove,
            message: Constants.Message.yourMove,
            leftButtonTitle: Constants.Button.rollDice,
            actionLeftButton: rollCompletion,
            leftButtonSelectable: true
        )

        if playerManager.getCurrentPlayer().id == playerManager.getCurrentUserId() {
            delegate?.showAlert(model: model, twoButtons: false)
        }
    }

    func askJailOptions(payCompletion: @escaping () -> Void, rollCompletion: @escaping () -> Void) {
        let model = AlertModel(
            title: Constants.Title.jailOptions,
            message: Constants.Message.jailOptions,
            leftButtonTitle: String(format: Constants.Button.bail, Constants.Jail.bailAmount),
            rightButtonTitle: Constants.Button.rollDice,
            actionLeftButton: payCompletion,
            actionRightButton: rollCompletion,
            leftButtonSelectable: playerManager.getCurrentPlayer().money >= Constants.Jail.bailAmount,
            rightButtonSelectable: true
        )

        delegate?.showAlert(model: model, twoButtons: true)
    }
}
