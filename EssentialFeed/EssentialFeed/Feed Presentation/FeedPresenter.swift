//

import Foundation


public protocol FeedView {
    func display(viewModel: FeedViewModel)
}
public struct FeedViewModel {
    public let feeds: [FeedImage]
}

public final class FeedPresenter {

    public static func map(_ feeds: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feeds: feeds)
    }

    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")
    }

}
