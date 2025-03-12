//
//  PropertyTradeCell.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 08.03.2025.
//
import UIKit

final class PropertyTradeCell: UITableViewCell {

    // MARK: - Constants

    private enum Constants {
        static let textStackSpacing: CGFloat = 4
        static let mainStackSpacing: CGFloat = 12
        static let borderWidth: CGFloat = 0.5
        static let cornerRadius: CGFloat = 4
        static let colorViewSize: CGFloat = 20
        static let iconSize: CGFloat = 40
        static let verticalOffset: CGFloat = 8
        static let horizontalOffset: CGFloat = 16
    }

    // MARK: - Private properties

    private let colorView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with property: Property) {
        colorView.backgroundColor = property.color
        iconView.image = property.image
        titleLabel.text = property.name
        priceLabel.text = "\(property.price)K"
    }

    // MARK: - Private Methods

    private func setupViews() {
        colorView.layer.cornerRadius = Constants.cornerRadius
        colorView.layer.borderWidth = Constants.borderWidth
        colorView.layer.borderColor = UIColor.tertiaryLabel.cgColor

        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .preferredFont(forTextStyle: .body)
        priceLabel.font = .preferredFont(forTextStyle: .caption1)
        priceLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        textStack.axis = .vertical
        textStack.spacing = Constants.textStackSpacing

        let mainStack = UIStackView(arrangedSubviews: [colorView, iconView, textStack])
        mainStack.spacing = Constants.mainStackSpacing
        mainStack.alignment = .center

        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: Constants.colorViewSize),
            colorView.heightAnchor.constraint(equalToConstant: Constants.colorViewSize)
        ])

        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: Constants.iconSize)
        ])

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalOffset),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalOffset),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalOffset),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalOffset)
        ])
    }
}
