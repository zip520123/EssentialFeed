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
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Swift.Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {

        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })

        let controller = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        
        presentationAdapter.presenter = LoadResourcePresenter(
            feedErrorView: WeakRefVirturalProxy(controller),
            loadingView: WeakRefVirturalProxy(controller),
            resourceView: FeedViewAdapter(controller: controller, imageLoader: { imageLoader($0).dispatchOnMainQueue() } ),
            mapper: FeedPresenter.map
            )
         
        return controller
    }
    
}

extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        
        controller.title = title
        controller.delegate = delegate
        return controller
    }
}

final class FeedViewAdapter: ResourceView {

    init(controller: FeedViewController, imageLoader: @escaping (URL)->FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    private weak var controller: FeedViewController?
    private let imageLoader: (URL)->FeedImageDataLoader.Publisher
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feeds.map { feed in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirturalProxy<FeedImageCellController>, UIImage>(model: feed, imageLoader: imageLoader)
            let view = FeedImageCellController(adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirturalProxy(view),
                imageTransformer: UIImage.init)
            
            return view
            
        })
        
    }
}

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: (URL)->FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: @escaping (URL)->FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model

        cancellable = imageLoader(model.imageURL).sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                break
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }, receiveValue: { [weak self] data in
            self?.presenter?.didFinishLoadingImageData(with: data!, for: model)
        })

    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {

    private var feedLoader: () -> AnyPublisher<[FeedImage], Swift.Error>
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?

    private var cancellable: Cancellable?

    init(feedLoader: @escaping ()->AnyPublisher<[FeedImage], Swift.Error>) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        loadFeed()
    }
    
    func loadFeed() {
        presenter?.didStartLoading()

        cancellable = feedLoader().sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)

                }
            }, receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoading(with: feed)
            })

    }
}

private final class WeakRefVirturalProxy<T: AnyObject> {
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

extension WeakRefVirturalProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageCellViewModel<UIImage>) {
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

