public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}
public class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    let feedErrorView: FeedErrorView
    let loadingView: ResourceLoadingView
    let resourceView: View
    let mapper: Mapper

    public init(feedErrorView: FeedErrorView, loadingView: ResourceLoadingView, resourceView: View, mapper: @escaping Mapper) {
        self.feedErrorView = feedErrorView
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    public func didStartLoading() {
        feedErrorView.display(FeedErrorViewModel(errorMessage: nil))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
    }
    public func didFinishLoading(with resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
    }
    public func didFinishLoading(with error: Error) {
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
        feedErrorView.display(FeedErrorViewModel(errorMessage: FeedPresenter.feedLoadError))
    }


    static var feedLoadError: String {
        NSLocalizedString("GENERIC_CONNECTION_ERROR",
                          tableName: "Shared",
                          bundle: Bundle(for: Self.self),
                          comment: "Error message displayed when we can't load the resource from the server")

    }

}
