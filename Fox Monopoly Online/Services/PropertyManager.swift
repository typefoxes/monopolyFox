//
//  PropertyManager.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 11.02.2025.
//

import UIKit

protocol PropertyManagerProtocol {
    /// Обновить владельца объекта
    /// - Parameters:
    ///   - propertyId: идентификатор объекта
    ///   - ownerId: идентификатор игрока
    ///   - fieldColor: назначаемый цвет
    func updatePropertyOwner(
        propertyId: Int,
        ownerId: String?,
        fieldColor: UIColor
    )
    /// Получить все объекты во владении игрока по идентификатору
    /// - Parameter playerId: идентификатор игрока
    /// - Returns: массив моделей объектов
    func getProperties(for playerId: String) -> [Property]
    /// Получить объект по его идентификатору (позиции)
    /// - Parameter position: позиция
    /// - Returns: модель объекта
    func getProperty(at position: Int) -> Property?
    /// Обновить количество отелей на объекте
    /// - Parameters:
    ///   - propertyId: идентификатор объекта
    ///   - buildings: количество отелей
    func updatePropertyBuildings(propertyId: Int, buildings: Int)
    /// Заложить объект
    /// - Parameter propertyId: идентификатор объекта
    func mortgageProperty(propertyId: Int)
    /// Выкупить объект
    /// - Parameter propertyId: идентификатор объекта
    func redeemProperty(propertyId: Int)
    /// Получить все объекты поля
    /// - Returns: массив объектов
    func getAllProperties() -> [Property]
    /// Игрок сдался
    /// - Parameter playerId: идентификатор владельца объектов
    func surrender(playerId: String)
    /// Проверка доступности строительства на объекте
    /// - Parameter property: модель объекта
    /// - Returns: флаг
    func canBuild(on property: Property) -> Bool
    /// Проверка доступности продажи отеля на объекте
    /// - Parameter property: модель объекта
    /// - Returns: флаг
    func canSellBuild(on property: Property) -> Bool
    /// Проверка доступности залога объекта
    /// - Parameter property: модель объекта
    /// - Returns: флаг
    func canMortgage(_ property: Property) -> Bool
    /// Сбросить попытки строительства за ход
    func resetBuiltThisTurn()
    /// Записать строительство на группе объектов на этот ход
    /// - Parameter property: модель объекта
    func writeBuild(_ property: Property)
    /// Обновить объекты
    /// - Parameter properties: массив объектов
    func updateProperties(_ properties: [Property])
    /// Проверка возможности добавить объект в торговый договор
    /// - Parameter selectedProperty: модель объекта
    /// - Returns: флаг
    func shouldAddToOffer(selectedProperty: Property) -> Bool
}

final class PropertyManager: PropertyManagerProtocol {

    // MARK: - Constants

    private enum Constants {
        static let maxBuildings: Int = 5
    }

    // MARK: - Private properties

    private var properties: [Property] = PropertyType.allCases.map { Property(type: $0) }
    private var hasBuiltThisTurn: [PropertyType: Bool] = [:]

    // MARK: - PropertyManagerProtocol

    func updateProperties(_ properties: [Property]) {
        self.properties = properties
    }

    func updatePropertyOwner(propertyId: Int, ownerId: String?, fieldColor: UIColor) {
        if let index = properties.firstIndex(where: { $0.position == propertyId }) {
            properties[index].owner = ownerId
            properties[index].fieldColor = fieldColor
        }
    }

    func getProperties(for playerId: String) -> [Property] {
        return properties.filter { $0.owner == playerId }
    }

    func getProperty(at position: Int) -> Property? {
        return properties.first { $0.position == position }
    }

    func updatePropertyBuildings(propertyId: Int, buildings: Int) {
        if let index = properties.firstIndex(where: { $0.position == propertyId }) {
            properties[index].buildings += buildings
        }
    }

    func mortgageProperty(propertyId: Int) {
        if let index = properties.firstIndex(where: { $0.position == propertyId }) {
            properties[index].active = false
        }
    }

    func redeemProperty(propertyId: Int) {
        if let index = properties.firstIndex(where: { $0.position == propertyId }) {
            properties[index].active = true
        }
    }

    func getAllProperties() -> [Property] {
        return properties
    }

    func surrender(playerId: String) {
        properties = properties.map {
            var updatedProperty = $0

            if updatedProperty.owner == playerId {
                updatedProperty.owner = nil
                updatedProperty.fieldColor = .white
                updatedProperty.active = true
                updatedProperty.buildings = .zero
            }
            return updatedProperty
        }
    }

    func canBuild(on property: Property) -> Bool {
        guard let group = property.group,
              property.canUpgrade,
              hasBuiltThisTurn[property.group?.first ?? property.type] != true,
              let currentOwnerId = property.owner else {
            return false
        }
        let groupProperties = properties.filter { group.contains($0.type) }
        let allOwnedBySame = groupProperties.allSatisfy { $0.owner == currentOwnerId }
        let minBuildingsInGroup = groupProperties.map { $0.buildings }.min() ?? .zero
        let buildingConditions = property.buildings <= minBuildingsInGroup && property.buildings < Constants.maxBuildings && property.active

        return allOwnedBySame && buildingConditions
    }

    func canSellBuild(on property: Property) -> Bool {
        guard let group = property.group, property.cardType == .streets else { return false }
        let groupProperties = properties.filter { group.contains($0.type) }
        let maxBuildingsInGroup = groupProperties.map { $0.buildings }.max() ?? .zero

        return property.buildings >= maxBuildingsInGroup && property.buildings > .zero
    }

    func canMortgage(_ property: Property) -> Bool {
        guard let group = property.group, property.cardType == .streets else { return false }
        let groupProperties = properties.filter { group.contains($0.type) }
        return !groupProperties.contains { $0.buildings > .zero }
    }

    func resetBuiltThisTurn() {
        hasBuiltThisTurn.removeAll()
    }

    func writeBuild(_ property: Property) {
        if let group = property.group {
            for type in group {
                hasBuiltThisTurn[type] = true
            }
        }
    }

    func shouldAddToOffer(selectedProperty: Property) -> Bool {
        guard let group = selectedProperty.group, selectedProperty.cardType == .streets else { return false }
        let groupProperties = properties.filter { group.contains($0.type) }
        return !groupProperties.contains { $0.buildings > .zero }
    }
}
