//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 01/11/2021.
//

import UIKit

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? refreshControl?.beginRefreshing() : refreshControl?.endRefreshing()
    }
    
    var delegate: FeedViewControllerDelegate?

    var feeds: [FeedImageCellController] = [] {
        didSet { tableView.reloadData() }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "My Feed"
        refresh()
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cellController(for: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            cellController(for: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(for indexPath: IndexPath) -> FeedImageCellController {
        feeds[indexPath.row]
    }
    
    private func cancelCellControllerLoad(_ indexPath: IndexPath) {
        feeds[indexPath.row].cancelLoad()
    }
    
}
