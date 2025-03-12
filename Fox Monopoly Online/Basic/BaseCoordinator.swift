//
//  Untitled.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 03.03.2025.
//

import UIKit

/// Базовый протокол для реализации Coordinator.
protocol Coordinator: AnyObject {
    /// Список активных дочерних координаторов
    var childCoordinators: [Coordinator] { get set }
    /// Навигационный контроллер для управления ViewController'ами
    var navigationController: UINavigationController { get set }
    /// Запускает основной поток координатора
    func start()
    /// Добавляет дочерний координатор в иерархию
    /// - Parameter coordinator: Координатор для добавления
    func addChild(_ coordinator: Coordinator)
    /// Удаляет дочерний координатор из иерархии
    /// - Parameter coordinator: Координатор для удаления
    func removeChild(_ coordinator: Coordinator)
    /// Вернуться на корневой экран
    func popToRootViewController(animated: Bool)
}

extension Coordinator {
    /// Реализация по умолчанию: добавляет координатор в массив дочерних
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    /// Реализация по умолчанию: удаляет координатор по ссылочному совпадению
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }

    func popToRootViewController(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }
}

/// Базовый класс для всех координаторов
class BaseCoordinator: Coordinator {

    // MARK: -  Properties

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: -  Lifecycle

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: -  Methods

    func start() {
        fatalError("Надо переопределить start")
    }

    func coordinate(to coordinator: Coordinator) {
        addChild(coordinator)
        coordinator.start()
    }

    // MARK: -  Базовые методы навигации

    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }

    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }

    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.present(viewController, animated: animated)

        if let completion {
            completion()
        }
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated)
        if let completion {
            completion()
        }
    }
}
