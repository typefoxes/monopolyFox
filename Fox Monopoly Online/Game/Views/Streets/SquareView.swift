//
//  SquareView.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.02.2025.
//

import UIKit

final class SquareView: UIView {

    // MARK: - Private properties

   private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
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
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        layoutIfNeeded()
    }
}

// MARK: - PropertyConfigurable

extension SquareView: PropertyConfigurable {

    func updateProperty(property: Property, properties: [Property]) { }

    func configure(property: Property) {
        imageView.image = property.image
        backgroundColor = .white
        layoutIfNeeded()
    }
}
