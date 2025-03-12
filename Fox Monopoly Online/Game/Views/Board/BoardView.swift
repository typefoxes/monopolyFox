//
//  BoardView.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 05.02.2025.
//

import UIKit

protocol BoardViewDelegate: AnyObject {
    /// Поле выбрано
    /// - Parameters:
    ///   - property: данные поля
    ///   - view: вью
    func didSelectProperty(property: Property, view: UIView)
}

protocol PropertyConfigurable {
    /// Настроить вью
    /// - Parameter property: данные поля
    func configure(property: Property)
    /// Обновить поле
    /// - Parameters:
    ///   - property: данные поля
    ///   - properties: массив всех полей
    func updateProperty(property: Property, properties: [Property])
}

final class BoardView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let boardDivider: CGFloat = 13
        static let numberOfSreetsInSqare: CGFloat = 2
        static let streetSizeAdjustment: CGFloat = 0.555
        static let spacing: CGFloat = 0.5
        static let viewValue: Int = 1

        enum Tags {
            // Board
            static let board = 100

            // Squares
            static let start = 0
            static let cop = 30
            static let park = 20
            static let jail = 10

            // Up streets
            static let pinksOne = 1
            static let chanceOne = 2
            static let pinksTwo = 3
            static let moneyOne = 4
            static let porsche = 5
            static let yellowOne = 6
            static let chanceTwo = 7
            static let yellowTwo = 8
            static let yellowThree = 9

            // Right streets
            static let tinasOne = 11
            static let starbacksOne = 12
            static let tinasTwo = 13
            static let tinasThree = 14
            static let mercedes = 15
            static let blueOne = 16
            static let chanceThree = 17
            static let blueTwo = 18
            static let blueThree = 19

            // Down streets
            static let greensOne = 21
            static let chanceFour = 22
            static let greensTwo = 23
            static let greensThree = 24
            static let ferrari = 25
            static let lightBluesOne = 26
            static let lightBluesTwo = 27
            static let starbucksTwo = 28
            static let lightBluesThree = 29

            // Left streets
            static let lavanderThree = 31
            static let lavanderTwo = 32
            static let chanceSix = 33
            static let lavanderOne = 34
            static let audi = 35
            static let brilliant = 36
            static let greysOne = 37
            static let chanceFive = 38
            static let greysTwo = 39
        }
    }

    // MARK: - Direction

    private enum Direction {
        case up
        case left
        case right
        case down
    }

    // MARK: - Public properties

    weak var delegate: BoardViewDelegate?

    var boardSize: CGFloat = .zero {
        didSet {
            sqareSize = (boardSize / Constants.boardDivider) * Constants.numberOfSreetsInSqare
            streetSize = (boardSize / Constants.boardDivider) - Constants.streetSizeAdjustment
            setupSquareViews()
            setupUpStack()
            setupRightStack()
            setupDownStack()
            setupLeftStack()
        }
    }

    // MARK: - Private properties

    private var properties: [Property] = []
    private var sqareSize: CGFloat = .zero
    private var streetSize: CGFloat = .zero

    // MARK: Corner streets

    private lazy var startView = createView(type: SquareView.self, tag: Constants.Tags.start)
    private lazy var copView = createView(type: SquareView.self, tag: Constants.Tags.cop)
    private lazy var parkView = createView(type: SquareView.self, tag: Constants.Tags.park)
    private lazy var jailView = createView(type: SquareView.self, tag: Constants.Tags.jail)

    // MARK: UP streets

    private lazy var pinksOneView = createView(type: StreetsView.self, tag: Constants.Tags.pinksOne)
    private lazy var chanceOneView = createView(type: StreetsView.self, tag: Constants.Tags.chanceOne)
    private lazy var pinksTwoView = createView(type: StreetsView.self, tag: Constants.Tags.pinksTwo)
    private lazy var moneyOneView = createView(type: StreetsView.self, tag: Constants.Tags.moneyOne)
    private lazy var porsche = createView(type: StreetsView.self, tag: Constants.Tags.porsche)
    private lazy var yellowOneView = createView(type: StreetsView.self, tag: Constants.Tags.yellowOne)
    private lazy var chanceTwoView = createView(type: StreetsView.self, tag: Constants.Tags.chanceTwo)
    private lazy var yellowTwoView = createView(type: StreetsView.self, tag: Constants.Tags.yellowTwo)
    private lazy var yellowThreeView = createView(type: StreetsView.self, tag: Constants.Tags.yellowThree)

    // MARK: Right streets

    private lazy var tinasOneView = createView(type: StreetsRightView.self, tag: Constants.Tags.tinasOne)
    private lazy var starbacksOneView = createView(type: StreetsRightView.self, tag: Constants.Tags.starbacksOne)
    private lazy var tinasTwoView = createView(type: StreetsRightView.self, tag: Constants.Tags.tinasTwo)
    private lazy var tinasThreeView = createView(type: StreetsRightView.self, tag: Constants.Tags.tinasThree)
    private lazy var mercedes = createView(type: StreetsRightView.self, tag: Constants.Tags.mercedes)
    private lazy var blueOneView = createView(type: StreetsRightView.self, tag: Constants.Tags.blueOne)
    private lazy var chanceThreeView = createView(type: StreetsRightView.self, tag: Constants.Tags.chanceThree)
    private lazy var blueTwoView = createView(type: StreetsRightView.self, tag: Constants.Tags.blueTwo)
    private lazy var blueThreeView = createView(type: StreetsRightView.self, tag: Constants.Tags.blueThree)

    // MARK: Down streets

    private lazy var greensOneView = createView(type: StreetsView.self, tag: Constants.Tags.greensOne)
    private lazy var chanceFourView = createView(type: StreetsView.self, tag: Constants.Tags.chanceFour)
    private lazy var greensTwoView = createView(type: StreetsView.self, tag: Constants.Tags.greensTwo)
    private lazy var greensThreeView = createView(type: StreetsView.self, tag: Constants.Tags.greensThree)
    private lazy var ferrari = createView(type: StreetsView.self, tag: Constants.Tags.ferrari)
    private lazy var lightBluesOneView = createView(type: StreetsView.self, tag: Constants.Tags.lightBluesOne)
    private lazy var lightBluesTwoView = createView(type: StreetsView.self, tag: Constants.Tags.lightBluesTwo)
    private lazy var starbucksTwoView = createView(type: StreetsView.self, tag: Constants.Tags.starbucksTwo)
    private lazy var lightBluesThreeView = createView(type: StreetsView.self, tag: Constants.Tags.lightBluesThree)

    // MARK: Left streets

    private lazy var lavanderThreeView = createView(type: StreetsLeftView.self, tag: Constants.Tags.lavanderThree)
    private lazy var lavanderTwoView = createView(type: StreetsLeftView.self, tag: Constants.Tags.lavanderTwo)
    private lazy var chanceSixView = createView(type: StreetsLeftView.self, tag: Constants.Tags.chanceSix)
    private lazy var lavanderOneView = createView(type: StreetsLeftView.self, tag: Constants.Tags.lavanderOne)
    private lazy var audi = createView(type: StreetsLeftView.self, tag: Constants.Tags.audi)
    private lazy var brilliantView = createView(type: StreetsLeftView.self, tag: Constants.Tags.brilliant)
    private lazy var greysOneView = createView(type: StreetsLeftView.self, tag: Constants.Tags.greysOne)
    private lazy var chanceFiveView = createView(type: StreetsLeftView.self, tag: Constants.Tags.chanceFive)
    private lazy var greysTwoView = createView(type: StreetsLeftView.self, tag: Constants.Tags.greysTwo)

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tag = Constants.Tags.board
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getPropertyByTag(_ tag: Int) -> Property? {
        return properties.first { $0.position == tag }
    }

    // MARK: - Private functions

    private func setupConstraints(for views: [UIView], with size: CGSize, direction: Direction, anchorView: UIView) {

        for (index, view) in views.enumerated() {
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: size.width),
                view.heightAnchor.constraint(equalToConstant: size.height)
            ])

            switch direction {
                case .up:
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: index == .zero ? anchorView.trailingAnchor : views[index - Constants.viewValue].trailingAnchor, constant: Constants.spacing),
                        view.topAnchor.constraint(equalTo: topAnchor)
                    ])
                case .left:
                    NSLayoutConstraint.activate([
                        view.topAnchor.constraint(equalTo: index == .zero ? anchorView.bottomAnchor : views[index - Constants.viewValue].bottomAnchor, constant: Constants.spacing),
                        view.leadingAnchor.constraint(equalTo: leadingAnchor)
                    ])
                case .down:
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: index == .zero ? copView.trailingAnchor : views[index - Constants.viewValue].trailingAnchor, constant: Constants.spacing),
                        view.bottomAnchor.constraint(equalTo: bottomAnchor)
                    ])
                case .right:
                    NSLayoutConstraint.activate([
                        view.topAnchor.constraint(equalTo: index == .zero ? jailView.bottomAnchor : views[index - Constants.viewValue].bottomAnchor, constant: Constants.spacing),
                        view.trailingAnchor.constraint(equalTo: trailingAnchor)
                    ])
            }
        }
    }

    private func setupUpStack() {
        let views = [
            pinksOneView,
            chanceOneView,
            pinksTwoView,
            moneyOneView,
            porsche,
            yellowOneView,
            chanceTwoView,
            yellowTwoView,
            yellowThreeView
        ]

        setupConstraints(
            for: views,
            with: CGSize(width: streetSize, height: sqareSize),
            direction: .up,
            anchorView: startView
        )
    }

    private func setupRightStack() {
        let views = [
            tinasOneView,
            starbacksOneView,
            tinasTwoView,
            tinasThreeView,
            mercedes,
            blueOneView,
            chanceThreeView,
            blueTwoView,
            blueThreeView
        ]

        setupConstraints(
            for: views,
            with: CGSize(width: sqareSize, height: streetSize),
            direction: .right,
            anchorView: jailView
        )
    }

    private func setupDownStack() {
        let views = [
            lightBluesThreeView,
            starbucksTwoView,
            lightBluesTwoView,
            lightBluesOneView,
            ferrari,
            greensThreeView,
            greensTwoView,
            chanceFourView,
            greensOneView
        ]

        setupConstraints(
            for: views,
            with: CGSize(width: streetSize, height: sqareSize),
            direction: .down,
            anchorView: copView
        )
    }

    private func setupLeftStack() {
        let views = [
            greysTwoView,
            chanceFiveView,
            greysOneView,
            brilliantView,
            audi,
            lavanderOneView,
            chanceSixView,
            lavanderTwoView,
            lavanderThreeView
        ]

        setupConstraints(
            for: views,
            with: CGSize(width: sqareSize, height: streetSize),
            direction: .left,
            anchorView: startView
        )
    }

    private func setupSquareViews() {

        NSLayoutConstraint.activate([
            startView.topAnchor.constraint(equalTo: topAnchor),
            startView.leadingAnchor.constraint(equalTo: leadingAnchor),
            startView.widthAnchor.constraint(equalToConstant: sqareSize),
            startView.heightAnchor.constraint(equalToConstant: sqareSize),

            jailView.topAnchor.constraint(equalTo: topAnchor),
            jailView.trailingAnchor.constraint(equalTo: trailingAnchor),
            jailView.widthAnchor.constraint(equalToConstant: sqareSize),
            jailView.heightAnchor.constraint(equalToConstant: sqareSize),

            parkView.bottomAnchor.constraint(equalTo: bottomAnchor),
            parkView.trailingAnchor.constraint(equalTo: trailingAnchor),
            parkView.widthAnchor.constraint(equalToConstant: sqareSize),
            parkView.heightAnchor.constraint(equalToConstant: sqareSize),

            copView.bottomAnchor.constraint(equalTo: bottomAnchor),
            copView.leadingAnchor.constraint(equalTo: leadingAnchor),
            copView.widthAnchor.constraint(equalToConstant: sqareSize),
            copView.heightAnchor.constraint(equalToConstant: sqareSize),
        ])
    }

    private func createView<T: UIView>(type: T.Type, tag: Int) -> T {
        let view = type.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = tag
        addSubview(view)
        return view
    }

    // MARK: - Actions

    @objc private func handlePropertyTap(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        let tag = tappedView.tag

        if let property = getPropertyByTag(tag) {
            delegate?.didSelectProperty(property: property, view: tappedView)
        }
    }

    // MARK: - Public functions

    func updateAllProperties(properties: [Property]) {
        for property in properties {
            guard let view = viewWithTag(property.position) else { continue }

            if let configurableView = view as? PropertyConfigurable {
                configurableView.updateProperty(property: property, properties: properties)
            }
        }

        self.properties = properties
    }

    func configureViews(properties: [Property]) {
        for property in properties {
            if let view = viewWithTag(property.position) as? PropertyConfigurable {
                view.configure(property: property)
            }
        }

        self.properties = properties

        for subview in subviews {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePropertyTap(_:)))
            subview.addGestureRecognizer(tapGesture)
        }
    }
}
