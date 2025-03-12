//
//  EndGameScreen.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 02.03.2025.
//

import UIKit
import Lottie

protocol WinnerViewControllerDelegate: AnyObject {
    /// Закрыть экран и вернуться в лобби
    func didTapCloseButton()
}

final class WinnerViewController: UIViewController {

    // MARK: - Constants

    private struct Constants {
        static let winnerTextFormat = "Победитель:\n%@"
        static let closeButtonTitle = "Завершить игру"
        static let animationName = "Animation"
        static let winnerLabelFontSize: CGFloat = 32
        static let closeButtonFontSize: CGFloat = 20
        static let winnerLabelWeights: UIFont.Weight = .bold
        static let closeButtonWeights: UIFont.Weight = .medium
        static let textColor = UIColor.white
        static let closeButtonTextColor = UIColor.white
        static let closeButtonBackgroundColor = UIColor.systemBlue
        static let buttonWidth: CGFloat = 200
        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 10
        static let closeButtonBottomInset: CGFloat = -40
        static let labelHorizontalInset: CGFloat = 1
    }

    // MARK: - Private properties

    private let winnerLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textColor = Constants.textColor
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let closeButton: UIButton = {
        let button = ActionButton(style: .positive, title: Constants.closeButtonTitle)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let animationView = LottieAnimationView()
    private let winnerName: String

    weak var delegate: WinnerViewControllerDelegate?

    // MARK: - Lifecycle

    init(winnerName: String) {
        self.winnerName = winnerName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupFireworksAnimation()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .black
        winnerLabel.text = String(format: Constants.winnerTextFormat, winnerName)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubviews(animationView, winnerLabel, closeButton)
    }

    private func setupConstraints() {
        animationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            winnerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.labelHorizontalInset),
            winnerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.labelHorizontalInset),
            winnerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.closeButtonBottomInset),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),

            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Fireworks Animation

    private func setupFireworksAnimation() {
        let animation = LottieAnimation.named(Constants.animationName)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }

    // MARK: - Actions

    @objc private func closeButtonTapped() {
        delegate?.didTapCloseButton()
    }
}
