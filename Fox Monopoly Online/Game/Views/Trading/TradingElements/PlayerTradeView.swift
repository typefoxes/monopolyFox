//
//  PersonTradeView.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 07.02.2025.
//

import UIKit

final class PlayerTradeView: UIView {

    // MARK: - Constants

    private enum Constants {
        static var nameLabelFont: UIFont = UIDevice.isPad ? UIFont.systemFont(ofSize: 16, weight: .bold) : UIFont.systemFont(ofSize: 8, weight: .bold)
        static let colorViewCornerRadius: CGFloat = 4
        static let colorViewBorderWidth: CGFloat = 1
        static let stackSpacing: CGFloat = 2
        static let colorMultiplier: CGFloat = 0.4
        static let nameMultiplier: CGFloat = 0.4
        static let colorAlpha: CGFloat = 0.2
        static let minimumScaleFactor: CGFloat = 0.7
    }

    // MARK: - Private properties

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.nameLabelFont
        label.minimumScaleFactor = Constants.minimumScaleFactor
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.colorViewCornerRadius
        view.layer.borderWidth = Constants.colorViewBorderWidth
        return view
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [colorView, nameLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = Constants.stackSpacing

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.colorMultiplier),
            colorView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.colorMultiplier),
            nameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.nameMultiplier)
        ])
    }

    // MARK: - Public methods

    func configure(name: String, balance: Int, color: UIColor) {
        nameLabel.text = name
        colorView.backgroundColor = color.withAlphaComponent(Constants.colorAlpha)
        colorView.layer.borderColor = color.cgColor
    }
}

