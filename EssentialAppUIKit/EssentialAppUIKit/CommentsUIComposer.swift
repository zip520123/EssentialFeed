//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class CommentsUIComposer {
    private init() {}

    private typealias CommentsPresentationAdapter =  LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>

    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Swift.Error>) -> ListViewController {

        let presentationAdapter = CommentsPresentationAdapter(loader: { commentsLoader().dispatchOnMainQueue() })

        let controller = makeCommentsViewController(title: ImageCommentsPresenter.title)
        controller.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceErrorView: WeakRefVirturalProxy(controller),
            loadingView: WeakRefVirturalProxy(controller),
            resourceView: CommentsViewAdapter(controller: controller),
            mapper: { ImageCommentsPresenter.map($0) }
            )

        return controller
    }


    private static func makeCommentsViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController

        controller.title = title

        return controller
    }

}




final private class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?

    init(controller: ListViewController) {
        self.controller = controller
    }

    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { comment in
            CellController(id: comment, ImageCommentCellController(model: comment))
        })
    }

}
