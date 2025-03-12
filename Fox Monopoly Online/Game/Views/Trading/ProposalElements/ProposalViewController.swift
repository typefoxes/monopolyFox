//
//  ProposalViewController.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 10.02.2025.
//

import UIKit

final class ProposalViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let contentInset: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let doubleContentInset: CGFloat = 32
        static let containerTopMargin: CGFloat = 20
        static let containerBottomMargin: CGFloat = -20
        static let shadowOpacity: Float = 0.2
        static let shadowOffsetHeight: CGFloat = 4
        static let shadowRadius: CGFloat = 8
        static let animationDuration: TimeInterval = 0.3
        static let alphaLow: CGFloat = 0.3
        static let alphaHigh: CGFloat = 1
        static let buttonSize: CGSize = .init(width: 44, height: 44)
        static let rowHeight: CGFloat = 60
        static let maxTableHeight: CGFloat = 300
        static let buttonCornerRadius: CGFloat = 12
        static let colorViewSize: CGFloat = 20
        static let iconSize: CGFloat = 40
        static let titleLabelHeight: CGFloat = 50
        static let buttonsStackHeight: CGFloat = 50
        static let eyeFillImage = "eye.fill"
        static let eyeSlashFillImage = "eye.slash.fill"
        static let proposeDealText = "предлагает сделку"
        static let acceptButtonTitle = "Принять"
        static let rejectButtonTitle = "Отказать"
        static let youGetTitle: String = "Вы получаете:"
        static let youGiveTitle: String = "Вы отдаёте:"
        static let transparencyActiveTint = UIColor.systemBlue
        static let transparencyInactiveTint = UIColor.secondaryLabel
        static let titleLabelFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        static let minimumScaleFactor: CGFloat = 0.7
    }

    // MARK: - Private properties

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = Constants.shadowOpacity
        view.layer.shadowOffset = .init(width: .zero, height: Constants.shadowOffsetHeight)
        view.layer.shadowRadius = Constants.shadowRadius
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = .zero
        label.adjustsFontSizeToFitWidth = true
        label.font = Constants.titleLabelFont
        label.adjustsFontForContentSizeCategory = true
        label.minimumScaleFactor = Constants.minimumScaleFactor
        return label
    }()

    private let transparencyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Constants.eyeFillImage), for: .normal)
        button.tintColor = .secondaryLabel
        return button
    }()

    private lazy var sectionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.sectionSpacing
        return stack
    }()

    private let youGetSection = TradeSectionView(title: Constants.youGetTitle)
    private let youGiveSection = TradeSectionView(title: Constants.youGiveTitle)

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = Constants.contentInset
        stack.distribution = .fillEqually
        return stack
    }()

    private let acceptButton = ActionButton(style: .positive, title: Constants.acceptButtonTitle)
    private let rejectButton = ActionButton(style: .negative, title: Constants.rejectButtonTitle)

    private var isTransparent = false {
        didSet { updateTransparency() }
    }

    // MARK: - Public properies

    var acceptAction: (() -> Void)?

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
        setupViews()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(
            width: sectionsStack.frame.width,
            height: sectionsStack.frame.height
        )
    }

    // MARK: - Configuration

    func configure(with model: TradeViewModel) {
        titleLabel.text = "\(model.fromPlayer.name) \(Constants.proposeDealText)"

        youGetSection.configure(
            money: model.fromPlayerMoney,
            properties: model.fromPlayerProperties ?? []
        )

        youGiveSection.configure(
            money: model.toPlayerMoney,
            properties: model.toPlayerProperties ?? []
        )
    }

    // MARK: - Private methods

    private func setupViews() {
        view.backgroundColor = .clear
        view.addSubview(containerView)

        containerView.addSubviews(titleLabel, transparencyButton, scrollView, buttonsStack)
        scrollView.addSubview(sectionsStack)

        sectionsStack.addArrangedSubview(youGetSection)
        sectionsStack.addArrangedSubview(youGiveSection)

        buttonsStack.addArrangedSubview(rejectButton)
        buttonsStack.addArrangedSubview(acceptButton)
    }

    private func setupConstraints() {
        [containerView, titleLabel, transparencyButton, scrollView, sectionsStack, buttonsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.containerTopMargin),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.contentInset),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.contentInset),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.containerBottomMargin),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.contentInset),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentInset),
            titleLabel.trailingAnchor.constraint(equalTo: transparencyButton.leadingAnchor, constant: -Constants.contentInset),
            titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.titleLabelHeight),

            transparencyButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            transparencyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentInset),
            transparencyButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize.width),
            transparencyButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize.height),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.sectionSpacing),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -Constants.contentInset),

            sectionsStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            sectionsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.contentInset),
            sectionsStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.contentInset),
            sectionsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            sectionsStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Constants.doubleContentInset),

            buttonsStack.heightAnchor.constraint(equalToConstant: Constants.buttonsStackHeight),
            buttonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentInset),
            buttonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentInset),
            buttonsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.contentInset)
        ])
    }

    private func setupActions() {
        transparencyButton.addAction(
            UIAction { [weak self] _ in
                self?.isTransparent.toggle()
            },
            for: .touchUpInside
        )

        acceptButton.addAction(
            UIAction { [weak self] _ in
                self?.dismiss(animated: true) {
                    self?.acceptAction?()
                }
            },
            for: .touchUpInside
        )

        rejectButton.addAction(
            UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            },
            for: .touchUpInside
        )
    }

    private func updateTransparency() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.containerView.alpha = self.isTransparent ? Constants.alphaLow : Constants.alphaHigh
            self.transparencyButton.tintColor = self.isTransparent ? .systemBlue : .secondaryLabel
            self.transparencyButton.setImage(UIImage(systemName: self.isTransparent ? Constants.eyeSlashFillImage : Constants.eyeFillImage), for: .normal)
        }
    }
}
