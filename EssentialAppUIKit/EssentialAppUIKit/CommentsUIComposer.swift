//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class CommentsUIComposer {
    private init() {}

    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Swift.Error>) -> ListViewController {

        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: { commentsLoader().dispatchOnMainQueue() })

        let controller = ListViewController.makeWith(title: FeedPresenter.title)
        controller.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceErrorView: WeakRefVirturalProxy(controller),
            loadingView: WeakRefVirturalProxy(controller),
            resourceView: FeedViewAdapter(controller: controller, imageLoader: { _ in Empty<Data?, Error>().eraseToAnyPublisher() } ),
            mapper: FeedPresenter.map
            )

        return controller
    }

}

