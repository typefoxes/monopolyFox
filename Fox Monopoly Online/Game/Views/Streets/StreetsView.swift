//
//  StreetsView.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.02.2025.
//

import UIKit

final class StreetsView: UIView {

    // MARK: - Constants

    private struct Constants {
        static let priceLabelHeight: CGFloat = 10
        static let fontSizePhone: CGFloat = 7
        static let fontSizePad: CGFloat = 12
        static let rotation: Int = 90
        static let starSize: CGFloat = 8
        static let bigStarSizeMultiplier: CGFloat = 0.5
        static let starSpacing: CGFloat = 0
        static let padding: CGFloat = 2
        static let priceMultiplier: CGFloat = 0.2
        static let adjustColor: CGFloat = 0.3
        static let alphaLock: CGFloat = 0.5
        static let zeroPrice: String = "0k"
        static let starsIdentifier: String = "starView"
        static let maxStarsInRow: CGFloat = 4
        static let maxHotels: Int = 5
        static let starGapCount: Int = 1
    }

    // MARK: - Private properties

    private lazy var priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.textColor = .white
        priceLabel.font = UIFont.boldSystemFont(ofSize: UIDevice().userInterfaceIdiom == .pad ? Constants.fontSizePad : Constants.fontSizePhone)
        priceLabel.textAlignment = .center
        return priceLabel
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupView() {
        addSubviews(imageView, priceLabel)

        NSLayoutConstraint.activate([

            priceLabel.topAnchor.constraint(equalTo: topAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            priceLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.priceMultiplier),

            imageView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
        ])
    }

    private func removeOldStars() {
        for subview in self.subviews {
            if let imageView = subview as? UIImageView, imageView.accessibilityIdentifier == Constants.starsIdentifier {
                imageView.removeFromSuperview()
            }
        }
    }

    private func addStars(for count: Int) {
        guard count > .zero else { return }

        if count == Constants.maxHotels {
            addBigStar()
        } else {
            addSmallStars(count: count)
        }
    }

    private func addBigStar() {
        let starSize = bounds.height * Constants.bigStarSizeMultiplier
        let bigStarX = (self.bounds.width - starSize) / Constants.padding
        let bigStarY = self.bounds.height - starSize - Constants.padding

        let bigStarImageView = UIImageView(image: .star)
        bigStarImageView.accessibilityIdentifier = Constants.starsIdentifier
        bigStarImageView.frame = CGRect(x: bigStarX, y: bigStarY, width: starSize, height: starSize)
        self.addSubview(bigStarImageView)
    }

    private func addSmallStars(count: Int) {
        let starSize = bounds.width / Constants.maxStarsInRow
        let totalStarsWidth = CGFloat(count) * starSize + CGFloat(count - Constants.starGapCount) * Constants.starSpacing
        var startX = (bounds.width - totalStarsWidth) / Constants.padding

        for _ in .zero..<count {
            let starImageView = UIImageView(image: .star)
            starImageView.accessibilityIdentifier = Constants.starsIdentifier
            starImageView.frame = CGRect(
                x: startX,
                y: bounds.height - starSize - Constants.padding,
                width: starSize,
                height: starSize
            )
            self.addSubview(starImageView)

            startX += starSize + Constants.starSpacing
        }
    }
}

// MARK: - PropertyConfigurable

extension StreetsView: PropertyConfigurable {

    func configure(property: Property) {
        imageView.image = property.image
        priceLabel.text = "\(property.price)k"
        priceLabel.backgroundColor = property.color
        backgroundColor = .white
    }

    func updateProperty(property: Property, properties: [Property]) {
        imageView.image = property.image
        priceLabel.text = "\(property.price)k"
        backgroundColor = property.fieldColor.adjust(by: Constants.adjustColor)

        if property.active {
            if property.owner != nil {
                priceLabel.text = property.currentLabelValue(properties: properties)
            }
        } else if property.owner != nil {
            imageView.image = .lock
            priceLabel.text = Constants.zeroPrice
            backgroundColor = property.fieldColor.withAlphaComponent(Constants.alphaLock)
        }

        removeOldStars()
        addStars(for: property.buildings)
    }
}
