//
//  ActionButton.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 08.03.2025.
//

import UIKit

final class ActionButton: UIButton {

    // MARK: - Constants

    private enum Constants {
        static let verticalpOffset: CGFloat = 12
        static let horizontalOffset: CGFloat = 12
        static let cornerRadius: CGFloat = 12
    }

    // MARK: - Style

    enum Style {
        case positive, negative

        var backgroundColor: UIColor {
            switch self {
            case .positive: return .systemGreen
            case .negative: return .systemRed
            }
        }
    }

    // MARK: - Lifecycle

    convenience init(style: Style, title: String) {
        self.init(type: .system)

        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = style.backgroundColor
        configuration.baseForegroundColor = .white
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.verticalpOffset,
            leading: Constants.horizontalOffset,
            bottom: Constants.verticalpOffset,
            trailing: Constants.horizontalOffset
        )
        configuration.title = title
        configuration.titleAlignment = .center
        configuration.titleLineBreakMode = .byTruncatingTail
        configuration.cornerStyle = .medium
        self.configuration = configuration

        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.minimumScaleFactor = 0.7
        titleLabel?.numberOfLines = 1
        titleLabel?.lineBreakMode = .byWordWrapping
        layer.cornerRadius = Constants.cornerRadius
        setTitleColor(.white, for: .normal)
    }
}
