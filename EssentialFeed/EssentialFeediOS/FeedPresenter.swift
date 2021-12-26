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
    let feedView: FeedView
    let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")
    }
    
    func didStartLoadingFeed() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {[weak self] in
                self?.didStartLoadingFeed()
            }
            return
        }
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {[weak self] in
                self?.didFinishLoadingFeed(with: feed)
            }
            return
        }
        feedView.display(viewModel: FeedViewModel(feeds: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {[weak self] in
                self?.didFinishLoadingFeed(with: error)
            }
            return
        }
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
}
