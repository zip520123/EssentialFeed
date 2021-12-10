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
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func didStartLoadingFeed() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(viewModel: FeedViewModel(feeds: feed))
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
}
