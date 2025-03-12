//
//  Untitled.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 08.03.2025.
//

import UIKit

final class LogTableView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let estimatedRowHeight: CGFloat = 44
        static let cellIdentifier: String = "LogCell"
        static let rowCount: Int = 1
    }

    // MARK: - Private properties

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.estimatedRowHeight = Constants.estimatedRowHeight
        tv.rowHeight = UITableView.automaticDimension
        tv.allowsSelection = false
        return tv
    }()

    private var logs: [String] = []

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LogCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = UIView()

        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func scrollToBottom() {
        let lastRow = tableView.numberOfRows(inSection: .zero) - Constants.rowCount
        if lastRow >= .zero {
            tableView.scrollToRow(
                at: IndexPath(row: lastRow, section: .zero),
                at: .bottom,
                animated: true
            )
        }
    }

    // MARK: - Public methods

    func update(with logs: [String]) {
        let previousCount = self.logs.count
        self.logs = logs

        if logs.count - previousCount == Constants.rowCount {
            let indexPath = IndexPath(row: logs.count - Constants.rowCount, section: .zero)
            tableView.insertRows(at: [indexPath], with: .automatic)
        } else {
            tableView.reloadData()
        }

        scrollToBottom()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension LogTableView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! LogCell
        cell.configure(with: logs[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
}
