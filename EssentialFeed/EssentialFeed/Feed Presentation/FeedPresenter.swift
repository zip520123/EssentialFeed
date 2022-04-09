//

import Foundation


public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public struct FeedErrorViewModel {
    public let errorMessage: String?
}
public protocol FeedView {
    func display(viewModel: FeedViewModel)
}
public struct FeedViewModel {
    public let feeds: [FeedImage]
}
extension FeedErrorViewModel: Equatable {
}

public final class FeedPresenter {
    let feedErrorView: FeedErrorView
    let loadingView: ResourceLoadingView
    let feedView: FeedView

    public init(feedErrorView: FeedErrorView, loadingView: ResourceLoadingView, feedView: FeedView) {
        self.feedErrorView = feedErrorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    public func didStartLoadingFeed() {
        feedErrorView.display(FeedErrorViewModel(errorMessage: nil))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
    }
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feeds: feed))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
    }
    public func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
        feedErrorView.display(FeedErrorViewModel(errorMessage: FeedPresenter.feedLoadError))
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
