//
//  DiceService.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 11.02.2025.
//

protocol DiceServiceProtocol {
    /// Бросить кубики
    /// - Returns: Кубик 1, Кубик 2, Флаг дубля
    func rollDice() ->(
        dice1: Int,
        dice2: Int,
        isDouble: Bool
    )
    /// Флаг есть ли дубли
    /// - Returns: Значение флага
    func hasThreeDoubles() -> Bool
    /// Сбросить дубля
    func resetDoubles()
    /// Количество дублей
    func getDoubles() -> Int
    /// Получить значение текущих кубиков
    func getCurrentDices() -> Int
}

final class DiceService: DiceServiceProtocol {

    // MARK: - Constants

    private enum Constants {
        static let minValue: Int = 1
        static let maxValue: Int = 6
        static let maxDoubles: Int = 3
    }

    // MARK: - Private methods

    private var doubleRolls: Int = .zero
    private var currentDices: Int = .zero

    // MARK: - DiceServiceProtocol

    func rollDice() -> (dice1: Int, dice2: Int, isDouble: Bool) {
        let dice1 = Int.random(in: Constants.minValue...Constants.maxValue)
        let dice2 = Int.random(in: Constants.minValue...Constants.maxValue)
        let isDouble = dice1 == dice2

        if isDouble {
            doubleRolls += Constants.minValue
        } else {
            doubleRolls = .zero
        }

        currentDices = dice1 + dice2
        return (dice1, dice2, isDouble)
    }

    func hasThreeDoubles() -> Bool {
        return doubleRolls == Constants.maxDoubles
    }

    func resetDoubles() {
        doubleRolls = .zero
    }

    func getCurrentDices() -> Int {
        return currentDices
    }

    func getDoubles() -> Int {
        return doubleRolls
    }
}
