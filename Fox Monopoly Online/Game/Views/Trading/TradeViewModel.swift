//
//  TradeViewModel.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 14.02.2025.
//

struct TradeViewModel {
    var fromPlayer: Player
    var toPlayer: Player
    var fromPlayerProperties: [Property]?
    var toPlayerProperties: [Property]?
    var fromPlayerMoney: Int
    var toPlayerMoney: Int
}
