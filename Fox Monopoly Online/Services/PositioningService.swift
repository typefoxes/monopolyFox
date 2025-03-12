//
//  test.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 09.03.2025.
//

import UIKit

protocol PositioningServiceProtocol {
    /// Установить вью фишек
    /// - Parameter boardView: доска
    func setupPlayers(boardView: BoardView)
    /// Расставить фишки на поле
    /// - Parameters:
    ///   - position: позиция
    ///   - boardView: доска
    func positionPlayers(at position: Int, boardView: BoardView)
    /// Достать размеры клетки
    /// - Parameters:
    ///   - position: позиция
    ///   - boardView: доска
    /// - Returns: размеры
    func getFrameForPosition(_ position: Int, boardView: BoardView) -> CGRect?
    /// Передвинуть на одну клетку
    /// - Parameters:
    ///   - stepsRemaining: осталось шагов
    ///   - position: позиция
    ///   - isLastStep: флаг последнего шага
    ///   - boardView: доска
    ///   - completion: завершающее действие
    func moveOneStep(
        stepsRemaining: Int,
        position: Int,
        isLastStep: Bool,
        boardView: BoardView,
        completion: @escaping () -> Void
    )
    /// Передвинуть фишку без шагов
    /// - Parameters:
    ///   - position: позиция
    ///   - boardView: доска
    func movePlayerToPosition(position: Int, boardView: BoardView)
}

final class PositioningService: PositioningServiceProtocol {

    // MARK: - Constants

    private enum Constants {
        static let adjust: CGFloat = 0.3
        static let playerSize: CGSize = UIDevice.isPhone ? CGSize(width: 10, height: 10) : CGSize(width: 20, height: 20)
        static let playerRadius: CGFloat = UIDevice.isPhone ? 5 : 10
        static let playerBorderWidth: CGFloat = UIDevice.isPhone ? 2 : 5
        static let animationDuration: TimeInterval = 0.3
        static let spacingMultiplier: CGFloat = 0.6
    }

    // MARK: - Private properties

    private var playerViews: [UIView] = []
    private let playerManager: PlayerManagerProtocol

    // MARK: - Lifecycle

    init(playerManager: PlayerManagerProtocol) {
        self.playerManager = playerManager
    }

    // MARK: - PositioningServiceProtocol

    func setupPlayers(boardView: BoardView) {
        playerViews = playerManager.getPlayers().map { player in
            let playerView = UIView()
            playerView.backgroundColor = player.color.adjust(by: Constants.adjust)
            playerView.layer.borderColor = player.color.cgColor
            playerView.frame.size = Constants.playerSize
            playerView.layer.cornerRadius = Constants.playerRadius
            playerView.layer.borderWidth = Constants.playerBorderWidth
            playerView.accessibilityIdentifier = player.id
            boardView.addSubview(playerView)
            return playerView
        }
        DispatchQueue.main.async {
            self.positionPlayers(at: .zero, boardView: boardView)
        }
    }

    func positionPlayers(at position: Int, boardView: BoardView) {
        guard let cellFrame = getFrameForPosition(position, boardView: boardView) else { return }

        let playersAtPosition = playerManager.getPlayers().filter { $0.position == position }
        let playerViewsAtPosition = playerViews.filter { view in
            playersAtPosition.contains { $0.id == view.accessibilityIdentifier }
        }

        guard !playerViewsAtPosition.isEmpty, let playerSize = playerViewsAtPosition.first?.frame.size else { return }
        let positions = calculatePositions(for: playerViewsAtPosition.count, cellFrame: cellFrame, playerSize: playerSize)

        for (index, playerView) in playerViewsAtPosition.enumerated() where index < positions.count {
            UIView.animate(withDuration: Constants.animationDuration) {
                playerView.center = positions[index]
            }
        }
    }

    func getFrameForPosition(_ position: Int, boardView: BoardView) -> CGRect? {
        boardView.subviews.first { $0.tag == position }?.frame
    }

    func moveOneStep(
        stepsRemaining: Int,
        position: Int,
        isLastStep: Bool,
        boardView: BoardView,
        completion: @escaping () -> Void
    ) {
        guard let cellFrame = getFrameForPosition(position, boardView: boardView) else { return }
        let index = playerManager.getCurrentPlayerIndex()
        let playerView = playerViews[index]

        UIView.animate(withDuration: Constants.animationDuration, animations: {
            playerView.center = CGPoint(x: cellFrame.midX, y: cellFrame.midY)
        }, completion: { _ in
            if isLastStep { self.positionPlayers(at: position, boardView: boardView) }
            completion()
        })
    }

    func movePlayerToPosition(position: Int, boardView: BoardView) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.positionPlayers(at: position, boardView: boardView)
        }
    }

    // MARK: - Private Methods

    private func calculatePositions(
        for count: Int,
        cellFrame: CGRect,
        playerSize: CGSize
    ) -> [CGPoint] {
        let center = CGPoint(x: cellFrame.midX, y: cellFrame.midY)
        let spacing = playerSize.width * Constants.spacingMultiplier

        switch count {
            case 1:
                return [center]
            case 2:
                return [
                    CGPoint(x: center.x - spacing, y: center.y),
                    CGPoint(x: center.x + spacing, y: center.y)
                ]
            case 3:
                return [
                    CGPoint(x: center.x, y: center.y - spacing),
                    CGPoint(x: center.x - spacing, y: center.y + spacing),
                    CGPoint(x: center.x + spacing, y: center.y + spacing)
                ]
            case 4:
                return [
                    CGPoint(x: center.x - spacing, y: center.y - spacing),
                    CGPoint(x: center.x + spacing, y: center.y - spacing),
                    CGPoint(x: center.x - spacing, y: center.y + spacing),
                    CGPoint(x: center.x + spacing, y: center.y + spacing)
                ]
            default: return []
        }
    }
}
