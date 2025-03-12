//
//  SelfSizingTableView.swift
//  Fox Monopoly Online
//
//  Created by d.kotina on 08.03.2025.
//

import UIKit

final class SelfSizingTableView: UITableView {

    private enum Constants {
        static let rowHeight: CGFloat = 60
    }

    init() {
        super.init(frame: .zero, style: .plain)
        isScrollEnabled = false
        separatorStyle = .none
        backgroundColor = .clear
        rowHeight = Constants.rowHeight
        estimatedRowHeight = Constants.rowHeight
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: contentSize.width, height: contentSize.height)
    }

    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
}
