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
    
    @IBOutlet private(set) public weak var errorView: ErrorView!
    public var onRefresh: (()->())?

    private var feeds: [CellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var loadingController = [IndexPath: CellController]()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }

    public func display(_ cellControllers: [CellController]) {
        loadingController.removeAll()
        feeds = cellControllers

    }

    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.display(viewModel)
    }

    public func errorViewIsVisible() -> Bool {
        errorView.isVisible
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ds = cellController(for: indexPath).dataSource
        return ds.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = removeLoadingController(indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            let dsp = cellController(for: indexPath).dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(for: indexPath).dataSourcePrefetching
            dsp?.tableView!(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(for indexPath: IndexPath) -> CellController {
        let controller = feeds[indexPath.row]
        loadingController[indexPath] = controller
        return controller
    }
    
    private func removeLoadingController(_ indexPath: IndexPath) -> CellController? {
        let controller = loadingController[indexPath]
        loadingController[indexPath] = nil
        return controller
    }
    
}
