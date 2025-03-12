//
//  LogCell.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 08.03.2025.
//

import UIKit

final class LogCell: UITableViewCell {

    // MARK: - Constants

    private enum Constants {
        static let logLabelMinFontSize: UIFont = UIDevice.isPad ? UIFont.systemFont(ofSize: 13) : UIFont.systemFont(ofSize: 9)
        static let logLabelminimumScaleFactor: CGFloat = 0.7
        static let horizontalOffset: CGFloat = 8
        static let verticalOffset: CGFloat = 4
    }

    private let logLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.logLabelMinFontSize
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.minimumScaleFactor = Constants.logLabelminimumScaleFactor
        label.textColor = .white
        label.numberOfLines = .zero
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(logLabel)
        logLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalOffset),
            logLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalOffset),
            logLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalOffset),
            logLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalOffset)
        ])
    }

    func configure(with text: String) {
        logLabel.text = text
    }
}
