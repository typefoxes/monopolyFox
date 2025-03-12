//
//  TradeSectionView.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 08.03.2025.
//

import UIKit

final class TradeSectionView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let stackSpacing: CGFloat = 8
        static let cellIdentifier: String = "Cell"
        static let cornerRadius: CGFloat = 12
    }

    // MARK: - Private properties

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()

    private let moneyLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    private let tableView = SelfSizingTableView()
    private var dataSource: UITableViewDiffableDataSource<Int, Property>!

    // MARK: - Lifecycle

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupViews()
        setupDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(money: Int, properties: [Property]) {
        moneyLabel.text = "\(money)k"
        updateProperties(properties)
        tableView.isHidden = properties.isEmpty
    }

    // MARK: - Private methods

    private func setupViews() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, moneyLabel, tableView])
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupDataSource() {
        tableView.register(PropertyTradeCell.self, forCellReuseIdentifier: Constants.cellIdentifier)

        dataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, property in
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? PropertyTradeCell
                cell?.configure(with: property)
                return cell
            }
        )
    }

    private func updateProperties(_ properties: [Property]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Property>()
        snapshot.appendSections([.zero])
        snapshot.appendItems(properties)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
