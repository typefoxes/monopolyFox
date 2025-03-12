//
//  PlayerCell.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 06.02.2025.
//

import UIKit

final class PlayerCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants

    private enum Constants {
        static let circleViewBorderWidth: CGFloat = 3
        static let nameLabelFont: UIFont = UIFont.systemFont(ofSize: 13, weight: .bold)
        static let moneyLabelFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        static let minimumScaleFactor: CGFloat = 0.7
        static let contentCornerRadius: CGFloat = 10
        static let labelsPadding: CGFloat = 5
        static let playerCircleDevider: CGFloat = 2
        static let playerCircleTop: CGFloat = 10
        static let adjust: CGFloat = 0.3
        static let contentBorderWidth: CGFloat = 2
        static let cornerRadiusDevider: CGFloat = 4
    }

    // MARK: - Private properties

    private let playerCircleView: UIView = {
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.borderWidth = Constants.circleViewBorderWidth
        return circleView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Constants.nameLabelFont
        label.textColor = .white
        label.minimumScaleFactor = Constants.minimumScaleFactor
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        label.clipsToBounds = true
        return label
    }()

    private let moneyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Constants.moneyLabelFont
        label.textColor = .white
        label.minimumScaleFactor = Constants.minimumScaleFactor
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        label.clipsToBounds = true
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubviews(playerCircleView, nameLabel, moneyLabel)
        contentView.layer.cornerRadius = Constants.contentCornerRadius
        contentView.backgroundColor = .greys

        NSLayoutConstraint.activate([
            playerCircleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.playerCircleTop),
            playerCircleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playerCircleView.widthAnchor.constraint(equalToConstant: contentView.bounds.width / Constants.playerCircleDevider),
            playerCircleView.heightAnchor.constraint(equalToConstant: contentView.bounds.width / Constants.playerCircleDevider),

            nameLabel.topAnchor.constraint(equalTo: playerCircleView.bottomAnchor, constant: Constants.labelsPadding),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.labelsPadding),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.labelsPadding),

            moneyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.labelsPadding),
            moneyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moneyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.labelsPadding)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func configure(with player: Player) {
        playerCircleView.backgroundColor = player.color.adjust(by: Constants.adjust)
        playerCircleView.layer.borderColor = player.color.cgColor
        playerCircleView.layer.cornerRadius =  contentView.bounds.width / Constants.cornerRadiusDevider
        nameLabel.text = player.name
        moneyLabel.text = "\(player.money) k"

        if player.current && player.isActive {
            contentView.layer.borderWidth = Constants.contentBorderWidth
            contentView.layer.borderColor = UIColor.green.cgColor
        } else {
            contentView.layer.borderWidth = .zero
        }

        if !player.isActive {
            playerCircleView.backgroundColor = .darkGray
            nameLabel.textColor = .darkGray
            moneyLabel.textColor = .darkGray
            contentView.layer.borderWidth = .zero
        } else {
            nameLabel.textColor = .white
            moneyLabel.textColor = .white
        }
    }
}
