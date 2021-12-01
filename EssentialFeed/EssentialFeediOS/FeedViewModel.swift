//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 20/11/2021.
//

import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader
    
    init(_ feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load {[weak self] (result) in
            if let image = try? result.get() {
                self?.onFeedLoad?(image)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
