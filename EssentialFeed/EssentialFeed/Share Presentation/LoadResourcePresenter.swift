
public class LoadResourcePresenter {
    let feedErrorView: FeedErrorView
    let loadingView: FeedLoadingView
    let feedView: FeedView

    public init(feedErrorView: FeedErrorView, loadingView: FeedLoadingView, feedView: FeedView) {
        self.feedErrorView = feedErrorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    public func didStartLoading() {
        feedErrorView.display(FeedErrorViewModel(errorMessage: nil))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feeds: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    public func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
        feedErrorView.display(FeedErrorViewModel(errorMessage: FeedPresenter.feedLoadError))
    }


    static var feedLoadError: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")

    }

}
