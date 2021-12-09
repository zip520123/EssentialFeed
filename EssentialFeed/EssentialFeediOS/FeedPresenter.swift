//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 20/11/2021.
//

import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feeds: [FeedImage]
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader
    
    init(_ feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    func loadFeed() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
        feedLoader.load {[weak self] (result) in
            if let images = try? result.get() {
                self?.feedView?.display(viewModel: FeedViewModel(feeds: images))
            }
            self?.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
        }
    }
}
