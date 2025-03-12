//
//  PropertyTableViewCell.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 07.02.2025.
//

import UIKit

protocol PropertiesTableDelegate: AnyObject {
    /// Удалить элемент
    /// - Parameter property: данные собственности
    func didRemoveProperty(_ property: Property)
}

final class PropertyCell: UITableViewCell {

    // MARK: - Constants

    private enum Constants {
        static let colorViewBorderWidth: CGFloat = 1
        static let nameLabelMinFontSize: UIFont = UIDevice.isPad ? UIFont.systemFont(ofSize: 13) : UIFont.systemFont(ofSize: 9)
        static let priceLabelMinFontSize: UIFont = UIDevice.isPad ? UIFont.systemFont(ofSize: 9) : UIFont.systemFont(ofSize: 7)
        static let textStackSpacing: CGFloat = 2
        static let mainStackSpacing: CGFloat = 10
        static let colorViewMultiplier: CGFloat = 0.7
        static let mainStackVerticalSpacing: CGFloat = 5
        static let mainStackHorizontalSpacing: CGFloat = 10
        static let colorAdjust: CGFloat = 0.2
        static let nameLabelminimumScaleFactor: CGFloat = 0.7
        static let priceLabelminimumScaleFactor: CGFloat = 0.6
        static let maxNumberOfLine: Int = 1
        static let colorCornerDevider: CGFloat = 2
    }

    // MARK: - Private properties

    private let colorView: UIView = {
        let view = UIView()
        view.layer.borderWidth = Constants.colorViewBorderWidth
        view.layer.borderColor = UIColor.systemGray3.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.nameLabelMinFontSize
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = Constants.nameLabelminimumScaleFactor
        label.numberOfLines = Constants.maxNumberOfLine
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.priceLabelMinFontSize
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = Constants.priceLabelminimumScaleFactor
        label.textColor = .secondaryLabel
        label.numberOfLines = Constants.maxNumberOfLine
        return label
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupCellAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeFirstResponder: Bool { true }
    override var canBecomeFocused: Bool { false }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        priceLabel.text = nil
        colorView.backgroundColor = nil
        colorView.layer.borderColor = UIColor.systemGray3.cgColor
    }

    // MARK: - Private methods

    private func setupCellAppearance() {
        contentView.clipsToBounds = true
        preservesSuperviewLayoutMargins = true
        contentView.isUserInteractionEnabled = true
        backgroundColor = .clear
    }

    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        textStack.axis = .vertical
        textStack.distribution = .fillProportionally
        textStack.spacing = Constants.textStackSpacing

        let mainStack = UIStackView(arrangedSubviews: [colorView, textStack])
        mainStack.axis = .horizontal
        mainStack.distribution = .fill
        mainStack.spacing = Constants.mainStackSpacing
        mainStack.alignment = .center
        mainStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        contentView.addSubview(mainStack)

        colorView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.colorViewMultiplier),
            colorView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.colorViewMultiplier),

            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.mainStackVerticalSpacing),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.mainStackHorizontalSpacing),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.mainStackHorizontalSpacing),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.mainStackVerticalSpacing)
        ])

        DispatchQueue.main.async {
            self.colorView.layer.cornerRadius = self.colorView.bounds.width / Constants.colorCornerDevider
        }
    }

    // MARK: - Public methods

    func configure(with property: Property) {
        nameLabel.text = property.name
        priceLabel.text = "\(property.price.formattedWithSeparator) k"
        colorView.backgroundColor = property.color
        colorView.layer.borderColor = property.color.adjust(by: Constants.colorAdjust).cgColor
    }
}
