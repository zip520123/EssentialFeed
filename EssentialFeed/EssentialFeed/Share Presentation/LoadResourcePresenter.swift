public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}
public class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    let feedErrorView: FeedErrorView
    let loadingView: FeedLoadingView
    let resourceView: View
    let mapper: Mapper

    public init(feedErrorView: FeedErrorView, loadingView: FeedLoadingView, resourceView: View, mapper: @escaping Mapper) {
        self.feedErrorView = feedErrorView
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    public func didStartLoading() {
        feedErrorView.display(FeedErrorViewModel(errorMessage: nil))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    public func didFinishLoading(with resource: Resource) {
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
