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
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Swift.Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage)->() = { _ in }
    ) -> ListViewController {

        let presentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>(loader: { feedLoader().dispatchOnMainQueue() })

        let controller = ListViewController.makeWith(title: FeedPresenter.title)
        controller.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceErrorView: WeakRefVirturalProxy(controller),
            loadingView: WeakRefVirturalProxy(controller),
            resourceView: FeedViewAdapter(
                controller: controller,
                imageLoader: { imageLoader($0).dispatchOnMainQueue() },
                selection: selection
            ),
            mapper: { $0 }
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

    private weak var controller: ListViewController?
    private let imageLoader: (URL)->FeedImageDataLoader.Publisher
    private let selection: (FeedImage)->()
    private let currentFeed: [FeedImage: CellController]

    init(currentFeed: [FeedImage: CellController] = [:], controller: ListViewController, imageLoader: @escaping (URL)->FeedImageDataLoader.Publisher, selection: @escaping (FeedImage)->()) {
        self.currentFeed = currentFeed
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }

    
    func display(_ viewModel: Paginated<FeedImage>) {
        guard let controller = controller else { return }
        var currfeed = currentFeed
        let cells: [CellController] = viewModel.items.map { feed in
            if let cellController = currentFeed[feed] {
                return cellController
            }
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirturalProxy<FeedImageCellController>>(loader: { [imageLoader] in
                imageLoader(feed.imageURL).map {$0!}.eraseToAnyPublisher()
            })

            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(feed),
                delegate: adapter,
                selection: { [selection] in
                    selection(feed)
                }
            )

            adapter.presenter = LoadResourcePresenter(
                resourceErrorView: WeakRefVirturalProxy(view),
                loadingView: WeakRefVirturalProxy(view),
                resourceView: WeakRefVirturalProxy(view),
                mapper: { data in
                    guard let image = UIImage(data: data) else { throw InvalidImageData()}
                    return image
                })
            let cellController = CellController(id: feed, view)
            currfeed[feed] = cellController
            return cellController
        }

        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(cells)
            return
        }

        let loadMoreAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>(loader: loadMorePublisher)

        let loadMoreCellController = LoadMoreCellController(callBack: loadMoreAdapter.loadResource)

        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceErrorView: WeakRefVirturalProxy(loadMoreCellController),
            loadingView: WeakRefVirturalProxy(loadMoreCellController),
            resourceView: FeedViewAdapter(
                currentFeed: currfeed,
                controller: controller,
                imageLoader: imageLoader,
                selection: selection),
            mapper: { $0 })

        let loadMoreSection = [CellController(id: UUID(), loadMoreCellController)]
        controller.display(cells, loadMoreSection)
        
    }
}

private struct InvalidImageData: Error {}

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private var loader: () -> AnyPublisher<Resource, Swift.Error>
    var presenter: LoadResourcePresenter<Resource, View>?
    private var cancellable: Cancellable?
    private var isLoading: Bool = false

    init(loader: @escaping ()->AnyPublisher<Resource, Swift.Error>) {
        self.loader = loader
    }

    func loadResource() {
        guard isLoading == false else { return }
        presenter?.didStartLoading()
        isLoading = true
        cancellable = loader()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)

                }
                self?.isLoading = false
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

