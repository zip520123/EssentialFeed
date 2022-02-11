//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 20/11/2021.
//

import EssentialFeed







final class FeedPresenter {
    let feedView: FeedView
    let loadingView: FeedLoadingView
    let feedErrorView: FeedErrorView
    
    init(feedView: FeedView, loadingView: FeedLoadingView, feedErrorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.feedErrorView = feedErrorView
    }
    
    static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")
    }
    
    func didStartLoadingFeed() {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
        feedErrorView.display(FeedErrorViewModel(errorMessage: nil))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feeds: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
        feedErrorView.display(FeedErrorViewModel(errorMessage: error.localizedDescription))
    }
    
}
