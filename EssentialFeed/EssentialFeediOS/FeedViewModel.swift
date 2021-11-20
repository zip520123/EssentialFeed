//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 20/11/2021.
//

import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(_ feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private(set) var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    var onChange: ((FeedViewModel) -> ())?
    var onFeedLoad: (([FeedImage])->Void)?
    
    func loadFeed() {
        isLoading = true
        feedLoader.load {[weak self] (result) in
            if let image = try? result.get() {
                self?.onFeedLoad?(image)
            }
            self?.isLoading = false
        }
    }
}
