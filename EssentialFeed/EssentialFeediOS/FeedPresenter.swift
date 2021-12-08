//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 20/11/2021.
//

import EssentialFeed

protocol FeedLoadingView: class {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feeds: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader
    
    init(_ feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    weak var loadingView: FeedLoadingView?
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load {[weak self] (result) in
            if let images = try? result.get() {
                self?.feedView?.display(feeds: images)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
