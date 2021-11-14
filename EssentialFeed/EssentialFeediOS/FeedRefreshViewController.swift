//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 14/11/2021.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let feedLoader: FeedLoader
    
    init(_ feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage])->Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load(completion: {[weak self] result in
            
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
            
        })
    }
}
