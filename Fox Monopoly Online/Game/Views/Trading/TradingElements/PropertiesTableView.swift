//
//  TradingElements.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 08.03.2025.
//

import UIKit

final class PropertiesTableView: UITableView {

    // MARK: - Constants

    private enum Constants {
        static var сellIdentifier: String = "Cell"
        static let estimatedRowHeight: CGFloat = UIDevice.isPad ? 80 : 60
        static let remove: String = "Удалить"
    }

    private var properties: [Property] = []
    weak var tableDelegate: PropertiesTableDelegate?

    // MARK: - Lifecycle

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private properties

    private func setup() {
        dataSource = self
        delegate = self
        register(PropertyCell.self, forCellReuseIdentifier: Constants.сellIdentifier)
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = Constants.estimatedRowHeight
        separatorStyle = .none
        allowsSelection = false
        isScrollEnabled = true
    }

    // MARK: - Public properties

    func add(_ property: Property) {
        properties.append(property)
        reloadData()
    }

    func remove(_ property: Property) {
        if let index = properties.firstIndex(of: property) {
            properties.remove(at: index)
            beginUpdates()
            deleteRows(at: [IndexPath(row: index, section: .zero)], with: .automatic)
            endUpdates()
        }
    }

    func clear() {
        properties.removeAll()
        reloadData()
    }
}
    // MARK: - UITableViewDataSource & UITableViewDelegate

extension PropertiesTableView:  UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        properties.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: Constants.сellIdentifier, for: indexPath) as? PropertyCell
        cell?.configure(with: properties[indexPath.row])
        return cell ?? PropertyCell()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: Constants.remove,
            handler: { [weak self] (action, view, completion) in
                guard let self else { return }

                let removedProperty = properties[indexPath.row]
                properties.remove(at: indexPath.row)

                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [indexPath], with: .left)
                } completion: { _ in
                    self.tableDelegate?.didRemoveProperty(removedProperty)
                    completion(true)
                }
            }
        )

        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

