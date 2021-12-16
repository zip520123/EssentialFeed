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
        
        let presentationAdapter = FeedLoaderPresentationAdapter()
        
        
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        
        
        controller.delegate = presentationAdapter
        
        let presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: controller, imageLoader: imageLoader),
            loadingView: WeakRefVirturalProxy(controller))
        presentationAdapter.presenter = presenter
        presentationAdapter.feedLoader = feedLoader
         
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

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {

    var feedLoader: FeedLoader?
    var presenter: FeedPresenter?
    
    func didRequestFeedRefresh() {
        loadFeed()
    }
    
    func loadFeed() {
        presenter?.didStartLoadingFeed()
        
        feedLoader?.load { [weak self] result in
            switch result {
            case let .success(feeds):
                self?.presenter?.didFinishLoadingFeed(with: feeds)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
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
