//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 14/11/2021.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    @IBOutlet private var view: UIRefreshControl?
    var delegate: FeedRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view?.beginRefreshing() : view?.endRefreshing()
    }
    
}
