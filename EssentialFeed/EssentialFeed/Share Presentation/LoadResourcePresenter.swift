public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}
public class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    let resourceErrorView: ResourceErrorView
    let loadingView: ResourceLoadingView
    let resourceView: View
    let mapper: Mapper

    public init(resourceErrorView: ResourceErrorView, loadingView: ResourceLoadingView, resourceView: View, mapper: @escaping Mapper) {
        self.resourceErrorView = resourceErrorView
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    public func didStartLoading() {
        resourceErrorView.display(ResourceErrorViewModel(errorMessage: nil))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
    }
    public func didFinishLoading(with resource: Resource) {
        do {
            resourceView.display(try mapper(resource))
            loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))

        } catch {
            didFinishLoading(with: error)
        }
    }
    public func didFinishLoading(with error: Error) {
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
        resourceErrorView.display(ResourceErrorViewModel(errorMessage: Self.feedLoadError))
    }


    static var feedLoadError: String {
        NSLocalizedString("GENERIC_CONNECTION_ERROR",
                          tableName: "Shared",
                          bundle: Bundle(for: Self.self),
                          comment: "Error message displayed when we can't load the resource from the server")

    }

}
