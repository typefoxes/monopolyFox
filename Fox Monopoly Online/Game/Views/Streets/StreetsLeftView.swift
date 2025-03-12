//
//  Untitled.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 02.03.2025.
//

import UIKit

final class StreetsLeftView: UIView {

    // MARK: - Constants

    private struct Constants {
        static let fontSizePhone: CGFloat = 7
        static let fontSizePad: CGFloat = 12
        static let rotation: Int = -90
        static let starSpacing: CGFloat = 0
        static let alphaLock: CGFloat = 0.5
        static let adjustColor: CGFloat = 0.3
        static let starGapCount: Int = 1
        static let bigStarSizeMultiplier: CGFloat = 0.5
        static let priceMultiplier: CGFloat = 0.2
        static let padding: CGFloat = 2
        static let zeroPrice: String = "0k"
        static let starsIdentifier: String = "starView"
        static let maxHotels: Int = 5
        static let maxStarsInRow: CGFloat = 4
    }

    // MARK: - Private properties

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let labelContainer: UIView = {
        let view = UIView()
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: UIDevice().userInterfaceIdiom == .pad ? Constants.fontSizePad : Constants.fontSizePhone)
        label.textAlignment = .center
        label.rotation = Constants.rotation
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Private methods

    private func setupView() {
        addSubviews(imageView, labelContainer)
        labelContainer.addSubview(label)

        [imageView, labelContainer, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: Constants.padding),

            labelContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelContainer.topAnchor.constraint(equalTo: topAnchor),
            labelContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelContainer.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.priceMultiplier),

            label.centerXAnchor.constraint(equalTo: labelContainer.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: labelContainer.centerYAnchor)
        ])
    }

    private func removeOldStars() {
        subviews.filter { $0.accessibilityIdentifier == Constants.starsIdentifier }.forEach { $0.removeFromSuperview() }
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
        let starFrame = CGRect(
            x: bounds.width - starSize,
            y: (bounds.height - starSize) / Constants.padding,
            width: starSize,
            height: starSize
        )

        let starView = UIImageView(image: .star)
        starView.accessibilityIdentifier = Constants.starsIdentifier
        starView.frame = starFrame
        addSubview(starView)
    }

    private func addSmallStars(count: Int) {
        let starSize = bounds.height / Constants.maxStarsInRow
        let totalHeight = CGFloat(count) * starSize + CGFloat(count - Constants.starGapCount) * Constants.starSpacing
        var startY = (bounds.height - totalHeight) / Constants.padding
        let xPosition = bounds.width - starSize

        for _ in .zero..<count {
            let starFrame = CGRect(
                x: xPosition,
                y: startY,
                width: starSize,
                height: starSize
            )

            let starView = UIImageView(image: .star)
            starView.accessibilityIdentifier = Constants.starsIdentifier
            starView.frame = starFrame
            addSubview(starView)

            startY += starSize + Constants.starSpacing
        }
    }
}

// MARK: - PropertyConfigurable

extension StreetsLeftView: PropertyConfigurable {

    func configure(property: Property) {
        imageView.image = property.image
        label.text = "\(property.price)k"
        labelContainer.backgroundColor = property.color
        backgroundColor = .white
    }

    func updateProperty(property: Property, properties: [Property]) {
        imageView.image = property.image
        label.text = "\(property.price)k"
        backgroundColor = property.fieldColor.adjust(by: Constants.adjustColor)

        if property.active {
            if property.owner != nil {
                label.text = property.currentLabelValue(properties: properties)
            }
        } else if property.owner != nil {
            imageView.image = .lock
            label.text = Constants.zeroPrice
            backgroundColor = property.fieldColor.withAlphaComponent(Constants.alphaLock)
        }

        removeOldStars()
        addStars(for: property.buildings)
    }
}
