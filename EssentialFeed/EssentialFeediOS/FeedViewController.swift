//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 01/11/2021.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    private(set) var loader: FeedLoader?
    
    convenience public init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load(completion: {[weak self] (_) in
            self?.refreshControl?.endRefreshing()
        })
    }
}
