//

import Foundation


public protocol FeedView {
    func display(viewModel: FeedViewModel)
}
public struct FeedViewModel {
    public let feeds: [FeedImage]
}

public final class FeedPresenter {
    let feedErrorView: ResourceErrorView
    let loadingView: ResourceLoadingView
    let feedView: FeedView

    public init(feedErrorView: ResourceErrorView, loadingView: ResourceLoadingView, feedView: FeedView) {
        self.feedErrorView = feedErrorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    public func didStartLoadingFeed() {
        feedErrorView.display(ResourceErrorViewModel(errorMessage: nil))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
    }
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: Self.map(feed))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
    }
    public func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
        feedErrorView.display(ResourceErrorViewModel(errorMessage: FeedPresenter.feedLoadError))
    }

    public static func map(_ feeds: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feeds: feeds)
    }

    static var feedLoadError: String {
        NSLocalizedString("GENERIC_CONNECTION_ERROR",
                          tableName: "Shared",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")

    }

    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")
    }
}
