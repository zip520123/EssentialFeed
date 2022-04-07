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
    
    public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: FeedImageDataLoader) -> FeedViewController {

        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })

        let controller = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        
        presentationAdapter.presenter = FeedPresenter(
            feedErrorView: WeakRefVirturalProxy(controller),
            loadingView: WeakRefVirturalProxy(controller),
            feedView: FeedViewAdapter(controller: controller, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
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

private final class FeedViewAdapter: FeedView {
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    func display(viewModel: FeedViewModel) {
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
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data!, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {

    var feedLoader: () -> FeedLoader.Publisher
    var presenter: FeedPresenter?
    private var cancellable: Cancellable?

    init(feedLoader: @escaping ()->FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        loadFeed()
    }
    
    func loadFeed() {
        presenter?.didStartLoadingFeed()

        cancellable = feedLoader().sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingFeed(with: error)

                }
            }, receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoadingFeed(with: feed)
            })

    }
}

private final class WeakRefVirturalProxy<T: AnyObject> {
    private weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirturalProxy: FeedLoadingView where T: FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

extension WeakRefVirturalProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageCellViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirturalProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {

    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        return ImmediateWhenOnMainQueueScheduler()
    }

    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        var now: DispatchQueue.SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                DispatchQueue.main.schedule(options: options, action)
                return
            }
            action()
        }

        func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }

        func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }


    }
}
