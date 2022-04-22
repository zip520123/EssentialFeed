//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 01/11/2021.
//

import UIKit
import EssentialFeed

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {

    public func display(viewModel: ResourceLoadingViewModel) {
        viewModel.isLoading ? refreshControl?.beginRefreshing() : refreshControl?.endRefreshing()
    }
    
    public let errorView = ErrorView()
    public var onRefresh: (()->())?

    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, controller in
            controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        configureErrorView()
        refresh()
    }

    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor).isActive = true
        errorView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor).isActive = true

        tableView.tableHeaderView = container
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }

    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.apply(snapshot)
    }

    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.display(viewModel)
    }

    public func errorViewIsVisible() -> Bool {
        errorView.isVisible
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(for: indexPath)?.delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(for: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            let dsp = cellController(for: indexPath)?.dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(for: indexPath)?.dataSourcePrefetching
            dsp?.tableView!(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(for indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
}
