//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 16/11/2021.
//

import UIKit
import EssentialFeed

final class FeedImageCellViewModel {
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    var location: String? {
        model.location
    }
    
    var description: String? {
        model.description
    }
    
    init(task: FeedImageDataLoaderTask? = nil, model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.task = task
        self.model = model
        self.imageLoader = imageLoader
    }
    
    typealias Observer<T> = (T)->()
    
    var didLoadImage: Observer<UIImage?>?
    var shouldHideButton: Observer<Bool>?
    var shimmering: Observer<Bool>?
    
    func loadImage() {
        shimmering?(true)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            let data = (try? result.get())
            let image = data.map(UIImage.init) ?? nil
            self?.didLoadImage?(image)
            self?.shouldHideButton?(image != nil)
            self?.shimmering?(false)
        }
    }
    
    func cancel() {
        task?.cancel()
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.imageURL, completion: { _ in })
    }
    
}

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        
        let vm = FeedViewModel(feedLoader)
        let refreshController = FeedRefreshViewController(vm)
        let controller = FeedViewController(refreshController: refreshController)
        vm.onFeedLoad = adaptFeedToCellControllers(controller, imageLoader)
         
        return controller
    }
    
    fileprivate static func adaptFeedToCellControllers(_ controller: FeedViewController, _ imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> () {
        return { [weak controller] feeds in
            controller?.feeds = feeds.map { feed in
                let viewModel = FeedImageCellViewModel(model: feed, imageLoader: imageLoader)
                return FeedImageCellController(viewModel)
            }
        }
    }
    
}
