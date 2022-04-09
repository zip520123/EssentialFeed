public protocol ResourceView {
    func display(_ viewModel: String)
}
public class LoadResourcePresenter {
    public typealias Mapper = (String)->String
    let feedErrorView: FeedErrorView
    let loadingView: FeedLoadingView
    let resourceView: ResourceView
    let mapper: Mapper

    public init(feedErrorView: FeedErrorView, loadingView: FeedLoadingView, resourceView: ResourceView, mapper: @escaping Mapper) {
        self.feedErrorView = feedErrorView
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    public func didStartLoading() {
        feedErrorView.display(FeedErrorViewModel(errorMessage: nil))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    public func didFinishLoading(with resource: String) {
        resourceView.display(mapper(resource))
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
