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
        let presenter = FeedPresenter(feedLoader)

        let refreshController = FeedRefreshViewController(presenter)
        let controller = FeedViewController(refreshController: refreshController)
        presenter.loadingView = refreshController
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
    
    func display(feeds: [FeedImage]) {
        controller?.feeds = feeds.map { feed in
            let viewModel = FeedImageCellViewModel<UIImage>(model: feed, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel)
        }
        
    }
    
}
