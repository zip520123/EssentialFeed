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
        
        let vm = FeedViewModel(feedLoader)
        let refreshController = FeedRefreshViewController(vm)
        let controller = FeedViewController(refreshController: refreshController)
        vm.onFeedLoad = adaptFeedToCellControllers(controller, imageLoader)
         
        return controller
    }
    
    fileprivate static func adaptFeedToCellControllers(_ controller: FeedViewController, _ imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> () {
        return { [weak controller] feeds in
            controller?.feeds = feeds.map { feed in
                let viewModel = FeedImageCellViewModel<UIImage>(model: feed, imageLoader: imageLoader, imageTransformer: UIImage.init)
                return FeedImageCellController(viewModel)
            }
        }
    }
    
}
