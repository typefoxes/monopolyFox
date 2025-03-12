//
//  Property.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 11.02.2025.
//

import UIKit

/// Модель данных собственности
struct Property: Equatable, Hashable {
    /// Тип
    let type: PropertyType
    /// Владелец
    var owner: String? = nil
    /// Отели
    var buildings: Int = .zero
    /// Флаг активности поля
    var active: Bool = true
    /// Цвет поля
    var fieldColor: UIColor = .white
    /// Название
    var name: String { type.data.name }
    /// Цена
    var price: Int { type.data.price }
    /// Позиция поля
    var position: Int { type.data.position }
    /// Стоимость залога
    var lockMoney: Int { type.data.lockMoney }
    /// Стоимости выкупа
    var rebuyMoney: Int { type.data.rebuyMoney }
    /// Цвет лейбла
    var color: UIColor { type.data.color }
    /// Изображение
    var image: UIImage { type.data.image }
    /// Группа
    var group: [PropertyType]? { type.data.group }
    /// Флаг возможности апгрейда
    var canUpgrade: Bool { type.data.canUpgrade }
    /// Тип карты
    var cardType: CardTypes { type.data.cardType }
    /// Цена строительства
    var buidPrice: Int { type.data.buidPrice }

    /// Расчет стоимости и ренты
    func currentLabelValue(properties: [Property]) -> String {
        if owner == nil {
            return "\(price)k"
        } else {
            if position == 12 || position == 28 {
                let ownerOwnsAllGroup = ownsAllGroup(ownerID: owner ?? String.empty, properties: properties)
                return ownerOwnsAllGroup ? "x250" : "x100"
            } else {
                let rentValue = "\(rent(properties: properties))k"
                return rentValue
            }
        }
    }

    /// Метод расчета ренты
    func rent(diceRoll: Int = .zero, properties: [Property]? = []) -> Int {
        let ownerOwnsAllGroup = ownsAllGroup(ownerID: owner ?? String.empty, properties: properties)

        switch position {
        case 12, 28:
            let multiplier = ownerOwnsAllGroup ? 250 : 100
            return diceRoll * multiplier

        case 5, 15, 25, 35:
            let ownedCount = countOwnedInGroup(ownerID: owner ?? String.empty, properties: properties)

            switch ownedCount {
                case 1:
                    return 250
                case 2:
                    return 500
                case 3:
                    return 1000
                case 4:
                    return 2000
                default:
                    return .zero
            }

        default:
            if buildings == .zero {
                return ownerOwnsAllGroup ? type.data.baseRent * 2 : type.data.baseRent
            } else {
                return type.data.rents[buildings - 1]
            }
        }
    }

    /// Проверка владения всей группой
    func ownsAllGroup(ownerID: String, properties: [Property]? = []) -> Bool {
        guard let group = type.data.group else { return false }
        return group.allSatisfy { groupType in
            properties?.first(where: { $0.type == groupType && $0.active })?.owner == ownerID
        }
    }

    /// Подсчет количества владений в группе
    func countOwnedInGroup(ownerID: String, properties: [Property]? = []) -> Int {
        var propGroup: [Property] = []

        guard let properties = properties else { return .zero }

        for property in properties {
            if property.position == 5 || property.position == 15 || property.position == 25 || property.position == 35 {
                if property.owner == ownerID && property.active {
                    propGroup.append(property)
                }
            }
        }

        return propGroup.count
    }
}

