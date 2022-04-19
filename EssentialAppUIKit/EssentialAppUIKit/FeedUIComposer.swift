//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 16/11/2021.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Swift.Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {

        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: { feedLoader().dispatchOnMainQueue() })

        let controller = ListViewController.makeWith(title: FeedPresenter.title)
        controller.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceErrorView: WeakRefVirturalProxy(controller),
            loadingView: WeakRefVirturalProxy(controller),
            resourceView: FeedViewAdapter(controller: controller, imageLoader: { imageLoader($0).dispatchOnMainQueue() } ),
            mapper: FeedPresenter.map
            )
         
        return controller
    }
    
}

extension ListViewController {
    static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        
        controller.title = title

        return controller
    }
}

final class FeedViewAdapter: ResourceView {

    init(controller: ListViewController, imageLoader: @escaping (URL)->FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    private weak var controller: ListViewController?
    private let imageLoader: (URL)->FeedImageDataLoader.Publisher
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feeds.map { feed in
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirturalProxy<FeedImageCellController>>(loader: { [imageLoader] in
                imageLoader(feed.imageURL).map {$0!}.eraseToAnyPublisher()
            })

            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(feed),
                delegate: adapter)
            
            adapter.presenter = LoadResourcePresenter(
                resourceErrorView: WeakRefVirturalProxy(view),
                loadingView: WeakRefVirturalProxy(view),
                resourceView: WeakRefVirturalProxy(view),
                mapper: { data in
                    guard let image = UIImage(data: data) else { throw InvalidImageData()}
                    return image
                })

            return CellController(id: feed, view)
            
        })
        
    }
}

private struct InvalidImageData: Error {}

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private var loader: () -> AnyPublisher<Resource, Swift.Error>
    var presenter: LoadResourcePresenter<Resource, View>?
    private var cancellable: Cancellable?

    init(loader: @escaping ()->AnyPublisher<Resource, Swift.Error>) {
        self.loader = loader
    }

    func loadResource() {
        presenter?.didStartLoading()

        cancellable = loader().sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)

                }
            }, receiveValue: { [weak self] resource in
                self?.presenter?.didFinishLoading(with: resource)
            })

    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}

final class WeakRefVirturalProxy<T: AnyObject> {
    private weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirturalProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

extension WeakRefVirturalProxy: ResourceView where T: ResourceView, T.ResourceViewModel == UIImage {
    func display(_ model: UIImage) {
        object?.display(model)
    }
}

extension WeakRefVirturalProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

