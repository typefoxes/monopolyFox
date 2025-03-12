//
//  Untitled.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 08.03.2025.
//

protocol LogManagerProtocol {
    /// Добавить лог на доску
    /// - Parameter message: сообщение
    func addLog(_ message: String)
    /// Массив с добавленными логами
    var logs: [String] { get }
}

final class LogManager: LogManagerProtocol {

    // MARK: - Constants

    private enum Constants {
        static let maxLogCount: Int = 20
    }

    // MARK: - Private properties

    private(set) var logs: [String] = []

    // MARK: - LogManagerProtocol

    func addLog(_ message: String) {
        logs.append(message)
        if logs.count > Constants.maxLogCount {
            logs.removeFirst()
        }
    }
}
