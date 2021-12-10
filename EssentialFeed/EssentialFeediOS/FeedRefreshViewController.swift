//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 14/11/2021.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private(set) lazy var view = loadView()
    let loadfeed: ()->()
    
    init(_ loadfeed: @escaping ()->()) {
        self.loadfeed = loadfeed
    }
    
    @objc func refresh() {
        loadfeed()
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
}
