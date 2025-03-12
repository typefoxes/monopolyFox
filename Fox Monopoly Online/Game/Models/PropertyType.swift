//
//  PropertyType.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 11.02.2025.
//

import UIKit

/// Модель данных для игровых полей
struct PropertyData {
    /// Название
    let name: String
    /// Цена
    let price: Int
    /// Позиция поля
    let position: Int
    /// Стоимость залога
    let lockMoney: Int
    /// Стоимость выкупа
    let rebuyMoney: Int
    /// Базовая рента
    let baseRent: Int
    /// Расчетная рента
    let rents: [Int]
    /// Группа
    let group: [PropertyType]?
    /// Цвет поля
    var color: UIColor
    /// Изображение
    var image: UIImage
    /// Флаг возможности апгрейда
    var canUpgrade: Bool
    /// Тип поля
    var cardType: CardTypes
    /// Цена строительства
    var buidPrice: Int
}

enum PropertyType: CaseIterable {
    case street1, street2, street3, street4, street5, street6, street7, street8, street9, street10,
         street11, street12, street13, street14, street15, street16, street17, street18, street19,
         street20, street21, street22, street23, street24, street25, street26, street27, street28,
         start, jail, park, cop, chanceOne, chanceTwo, chanceThree, chanceFour, chanceFive, chanceSix,
         moneyBag, brilliant

    var data: PropertyData {
        switch self {
        case .street1:
            return PropertyData(
                name: "Rexona",
                price: 600,
                position: 1,
                lockMoney: 300,
                rebuyMoney: 360,
                baseRent: 20,
                rents: [100, 300, 900, 1600, 2500],
                group: [.street1, .street2],
                color: .pinks,
                image: ._1,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 500
            )
        case .street2:
            return PropertyData(
                name: "Золотое яблоко",
                price: 600,
                position: 3,
                lockMoney: 300,
                rebuyMoney: 360,
                baseRent: 40,
                rents: [200, 600, 1800, 3200, 4500],
                group: [.street1, .street2],
                color: .pinks,
                image: ._3,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 500
            )
        case .street3:
            return PropertyData(
                name: "PORSCHE",
                price: 2000,
                position: 5,
                lockMoney: 1000,
                rebuyMoney: 1200,
                baseRent: 250,
                rents: [500, 1000, 2000, 4000, 6000],
                group: [.street3, .street11, .street18, .street26],
                color: .reds,
                image: ._5,
                canUpgrade: false,
                cardType: .streets,
                buidPrice: .zero
            )
        case .street4:
            return PropertyData(
                name: "Nike",
                price: 1000,
                position: 6,
                lockMoney: 500,
                rebuyMoney: 600,
                baseRent: 60,
                rents: [300, 900, 2700, 4000, 5500],
                group: [.street4, .street5, .street6],
                color: .yellows,
                image: ._6,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 500
            )
        case .street5:
            return PropertyData(
                name: "Vans",
                price: 1000,
                position: 8,
                lockMoney: 500,
                rebuyMoney: 600,
                baseRent: 60,
                rents: [300, 900, 2700, 4000, 5500],
                group: [.street4, .street5, .street6],
                color: .yellows,
                image: ._8,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 500
            )
        case .street6:
            return PropertyData(
                name: "Converse",
                price: 1200,
                position: 9,
                lockMoney: 600,
                rebuyMoney: 720,
                baseRent: 80,
                rents: [400, 1000, 3000, 4500, 6000],
                group: [.street4, .street5, .street6],
                color: .yellows,
                image: ._9,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 500
            )
        case .street7:
            return PropertyData(
                name: "VK",
                price: 1400,
                position: 11,
                lockMoney: 700,
                rebuyMoney: 840,
                baseRent: 100,
                rents: [500, 1500, 4500, 6250, 7500],
                group: [.street7, .street9, .street10],
                color: .tinas,
                image: ._11,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 750
            )
        case .street8:
            return PropertyData(
                name: "Baskin Robbins",
                price: 1500,
                position: 12,
                lockMoney: 750,
                rebuyMoney: 900,
                baseRent: 1500,
                rents: [],
                group: [.street8, .street21],
                color: .browns,
                image: ._12,
                canUpgrade: false,
                cardType: .streets,
                buidPrice: .zero
            )
        case .street9:
            return PropertyData(
                name: "Instagram",
                price: 1400,
                position: 13,
                lockMoney: 700,
                rebuyMoney: 840,
                baseRent: 100,
                rents: [500, 1500, 4500, 6250, 7500],
                group: [.street7, .street9, .street10],
                color: .tinas,
                image: ._13,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 750
            )
        case .street10:
            return PropertyData(
                name: "Telegram",
                price: 1600,
                position: 14,
                lockMoney: 800,
                rebuyMoney: 960,
                baseRent: 120,
                rents: [600, 1800, 5000, 7000, 9000],
                group: [.street7, .street9, .street10],
                color: .tinas,
                image: ._14,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 750
            )
        case .street11:
            return PropertyData(
                name: "Mercedes",
                price: 2000,
                position: 15,
                lockMoney: 1000,
                rebuyMoney: 1200,
                baseRent: 250,
                rents: [500, 1000, 2000, 4000, 6000],
                group: [.street3, .street11, .street18, .street26],
                color: .reds,
                image: ._15,
                canUpgrade: false,
                cardType: .streets,
                buidPrice: .zero
            )
        case .street12:
            return PropertyData(
                name: "Боржоми",
                price: 1800,
                position: 16,
                lockMoney: 900,
                rebuyMoney: 1080,
                baseRent: 140,
                rents: [700, 2000, 5500, 7500, 9500],
                group: [.street12, .street13, .street14],
                color: .blues,
                image: ._16,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1000
            )
        case .street13:
            return PropertyData(
                name: "Добрый",
                price: 1800,
                position: 18,
                lockMoney: 900,
                rebuyMoney: 1080,
                baseRent: 140,
                rents: [700, 2000, 5500, 7500, 9500],
                group: [.street12, .street13, .street14],
                color: .blues,
                image: ._18,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1000
            )
        case .street14:
            return PropertyData(
                name: "Черноголовка",
                price: 2000,
                position: 19,
                lockMoney: 1000,
                rebuyMoney: 1200,
                baseRent: 160,
                rents: [800, 2200, 6000, 8000, 10000],
                group: [.street12, .street13, .street14],
                color: .blues,
                image: ._19,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1000
            )
        case .street15:
            return PropertyData(
                name: "Beats",
                price: 2200,
                position: 21,
                lockMoney: 1100,
                rebuyMoney: 1320,
                baseRent: 180,
                rents: [900, 2500, 7000, 8750, 10500],
                group: [.street15, .street16, .street17],
                color: .greens,
                image: ._21,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1250
            )
        case .street16:
            return PropertyData(
                name: "Bang & Olufsen",
                price: 2200,
                position: 23,
                lockMoney: 1100,
                rebuyMoney: 1320,
                baseRent: 180,
                rents: [900, 2500, 7000, 8750, 10500],
                group: [.street15, .street16, .street17],
                color: .greens,
                image: ._23,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1250
            )
        case .street17:
            return PropertyData(
                name: "JBL",
                price: 2400,
                position: 24,
                lockMoney: 1200,
                rebuyMoney: 1440,
                baseRent: 200,
                rents: [1000, 3000, 9000, 11250, 12750],
                group: [.street15, .street16, .street17],
                color: .greens,
                image: ._24,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1250
            )
        case .street18:
            return PropertyData(
                name: "Ferrari",
                price: 2000,
                position: 25,
                lockMoney: 1000,
                rebuyMoney: 1200,
                baseRent: 250,
                rents: [500, 1000, 2000, 4000, 6000],
                group: [.street3, .street11, .street18, .street26],
                color: .reds,
                image: ._25,
                canUpgrade: false,
                cardType: .streets,
                buidPrice: .zero
            )
        case .street19:
            return PropertyData(
                name: "Burger King",
                price: 2600,
                position: 26,
                lockMoney: 1300,
                rebuyMoney: 1560,
                baseRent: 220,
                rents: [1100, 3300, 8000, 9750, 11500],
                group: [.street19, .street20, .street22],
                color: .lightBlues,
                image: ._26,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1500
            )
        case .street20:
            return PropertyData(
                name: "Dominos",
                price: 2600,
                position: 27,
                lockMoney: 1300,
                rebuyMoney: 1560,
                baseRent: 220,
                rents: [1100, 3300, 8000, 9750, 11500],
                group: [.street19, .street20, .street22],
                color: .lightBlues,
                image: ._27,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1500
            )
        case .street21:
            return PropertyData(
                name: "Stars Coffee",
                price: 1500,
                position: 28,
                lockMoney: 750,
                rebuyMoney: 900,
                baseRent: 1500,
                rents: [],
                group: [.street8, .street21],
                color: .browns,
                image: ._28,
                canUpgrade: false,
                cardType: .streets,
                buidPrice: .zero
            )
        case .street22:
            return PropertyData(
                name: "McDonald's",
                price: 2800,
                position: 29,
                lockMoney: 1400,
                rebuyMoney: 1680,
                baseRent: 240,
                rents: [1200, 3600, 8500, 10250, 12000],
                group: [.street19, .street20, .street22],
                color: .lightBlues,
                image: ._29,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1500
            )
        case .street23:
            return PropertyData(
                name: "Кинопоиск",
                price: 3000,
                position: 31,
                lockMoney: 1500,
                rebuyMoney: 1800,
                baseRent: 260,
                rents: [1300, 3900, 9000, 11000, 12750],
                group: [.street23, .street24, .street25],
                color: .lavanders,
                image: ._31,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1750
            )
        case .street24:
            return PropertyData(
                name: "Netflix",
                price: 3000,
                position: 32,
                lockMoney: 1500,
                rebuyMoney: 1800,
                baseRent: 260,
                rents: [1300, 3900, 9000, 11000, 12750],
                group: [.street23, .street24, .street25],
                color: .lavanders,
                image: ._32,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1750
            )
        case .street25:
            return PropertyData(
                name: "Ökko",
                price: 3200,
                position: 34,
                lockMoney: 1600,
                rebuyMoney: 1920,
                baseRent: 280,
                rents: [1500, 4500, 10000, 12000, 14000],
                group: [.street23, .street24, .street25],
                color: .lavanders,
                image: ._34,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 1750
            )
        case .street26:
            return PropertyData(
                name: "Audi",
                price: 2000,
                position: 35,
                lockMoney: 1000,
                rebuyMoney: 1200,
                baseRent: 250,
                rents: [500, 1000, 2000, 4000, 6000],
                group: [.street3, .street11, .street18, .street26],
                color: .reds,
                image: ._35,
                canUpgrade: false,
                cardType: .streets,
                buidPrice: .zero
            )
        case .street27:
            return PropertyData(
                name: "Sony PlayStation",
                price: 3500,
                position: 37,
                lockMoney: 1750,
                rebuyMoney: 2100,
                baseRent: 350,
                rents: [1750, 5000, 11000, 13000, 15000],
                group: [.street27, .street28],
                color: .greys,
                image: ._37,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 2000
            )
        case .street28:
            return PropertyData(
                name: "Apple",
                price: 4000,
                position: 39,
                lockMoney: 2000,
                rebuyMoney: 2400,
                baseRent: 500,
                rents: [2000, 6000, 14000, 17000, 20000],
                group: [.street27, .street28],
                color: .greys,
                image: ._39,
                canUpgrade: true,
                cardType: .streets,
                buidPrice: 2000
            )

            // Специальные поля
        case .start:
            return PropertyData(
                name: "Старт",
                price: .zero,
                position: .zero,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .startSqare,
                canUpgrade: false,
                cardType: .start,
                buidPrice: .zero
            )
        case .jail:
            return PropertyData(
                name: "Тюрьма",
                price: .zero,
                position: 10,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .jail,
                canUpgrade: false,
                cardType: .jail,
                buidPrice: .zero
            )
        case .park:
            return PropertyData(
                name: "Парк",
                price: .zero,
                position: 20,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .park,
                canUpgrade: false,
                cardType: .park,
                buidPrice: .zero
            )
        case .cop:
            return PropertyData(
                name: "Полиция",
                price: .zero,
                position: 30,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .cop,
                canUpgrade: false,
                cardType: .cop,
                buidPrice: .zero
            )
        case .chanceOne:
            return PropertyData(
                name: "Шанс",
                price: .zero,
                position: 2,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .chanceUp,
                canUpgrade: false,
                cardType: .chance,
                buidPrice: .zero
            )
        case .chanceTwo:
            return PropertyData(
                name: "Шанс",
                price: .zero,
                position: 7,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .chanceUp,
                canUpgrade: false,
                cardType: .chance,
                buidPrice: .zero
            )
        case .chanceThree:
            return PropertyData(
                name: "Шанс",
                price: .zero,
                position: 17,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .chanceRight,
                canUpgrade: false,
                cardType: .chance,
                buidPrice: .zero
            )
        case .chanceFour:
            return PropertyData(
                name: "Шанс",
                price: .zero,
                position: 22,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .chanceUp,
                canUpgrade: false,
                cardType: .chance,
                buidPrice: .zero
            )
        case .chanceFive:
            return PropertyData(
                name: "Шанс",
                price: .zero,
                position: 33,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .chanceLeft,
                canUpgrade: false,
                cardType: .chance,
                buidPrice: .zero
            )
        case .chanceSix:
            return PropertyData(
                name: "Шанс",
                price: .zero,
                position: 38,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: .zero,
                rents: [],
                group: nil,
                color: .white,
                image: .chanceLeft,
                canUpgrade: false,
                cardType: .chance,
                buidPrice: .zero
            )
        case .moneyBag:
            return PropertyData(
                name: "Подоходный налог",
                price: .zero,
                position: 4,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: 2000,
                rents: [],
                group: nil,
                color: .white,
                image: .money,
                canUpgrade: false,
                cardType: .tax,
                buidPrice: .zero
            )
        case .brilliant:
            return PropertyData(
                name: "Налог на роскошь",
                price: .zero,
                position: 36,
                lockMoney: .zero,
                rebuyMoney: .zero,
                baseRent: 1000,
                rents: [],
                group: nil,
                color: .white,
                image: .brilliant,
                canUpgrade: false,
                cardType: .tax,
                buidPrice: .zero
            )
        }
    }
}

/// Варианты игрровых полей
enum CardTypes {
    /// Налоги
    case tax
    /// Шанс
    case chance
    /// Улицы
    case streets
    /// Старт
    case start
    /// Полиция
    case cop
    /// Тюрьма
    case jail
    /// Парк
    case park
}
