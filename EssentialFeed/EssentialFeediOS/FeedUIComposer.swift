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
        
        let refreshController = FeedRefreshViewController(feedLoader)
        let controller = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = adaptFeedToCellControllers(controller, imageLoader)
        return controller
    }
    
    fileprivate static func adaptFeedToCellControllers(_ controller: FeedViewController, _ imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> () {
        return { [weak controller] feeds in
            controller?.feeds = feeds.map { feed in FeedImageCellController(model: feed, imageLoader: imageLoader) }
        }
    }
    
}
