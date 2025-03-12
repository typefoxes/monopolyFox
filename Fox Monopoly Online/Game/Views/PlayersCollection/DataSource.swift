//
//  DataSource.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 09.03.2025.
//

import UIKit
//
//  DataSource.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 09.03.2025.
//

import UIKit

final class PlayerCollectionViewDataSource: NSObject {

    // MARK: - Constants

    private struct Constants {
        static let reuseIdentifier = "PlayerCollectionViewCell"
        static let minimumHeightForLargeCell: CGFloat = 110
        static let cellWidthMargin: CGFloat = 10
        static let defaultCellWidth: CGFloat = 100
        static let defaultCellHeight: CGFloat = 110
        static let minInteritemSpacing: CGFloat = 30
        static let minLineSpacing: CGFloat = 10
    }

    // MARK: Private properties

    private let playerManager: PlayerManagerProtocol

    // MARK: Public properties

    var didSelectPlayer: ((Int, UIView) -> Void)?

    // MARK: Lifecycle

    init(playerManager: PlayerManagerProtocol) {
        self.playerManager = playerManager
    }
}

// MARK: - UICollectionViewDataSource

extension PlayerCollectionViewDataSource: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerManager.getPlayers().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.reuseIdentifier,
            for: indexPath
        ) as! PlayerCollectionViewCell

        let player = playerManager.getPlayers()[indexPath.item]
        cell.configure(with: player)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PlayerCollectionViewDataSource: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView.bounds.height < Constants.minimumHeightForLargeCell {
            return CGSize(
                width: collectionView.bounds.height - Constants.cellWidthMargin,
                height: collectionView.bounds.height
            )
        } else {
            return CGSize(
                width: Constants.defaultCellWidth,
                height: Constants.defaultCellHeight
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.minInteritemSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.minLineSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        didSelectPlayer?(indexPath.row, cell)
    }
}
