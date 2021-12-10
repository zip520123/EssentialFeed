//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 16/11/2021.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshViewController(presentationAdapter.loadFeed)
        let controller = FeedViewController(refreshController: refreshController)
        presenter.loadingView = WeakRefVirturalProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: controller, imageLoader: imageLoader)
         
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
        controller?.feeds = viewModel.feeds.map { feed in
            let viewModel = FeedImageCellViewModel<UIImage>(model: feed, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel)
        }
        
    }
    
}

private final class FeedLoaderPresentationAdapter {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func loadFeed() {
        presenter.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feeds):
                self?.presenter.didFinishLoadingFeed(with: feeds)
            case let .failure(error):
                self?.presenter.didFinishLoadingFeed(with: error)
            }
        }
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
