//
import UIKit
import EssentialFeediOS
import EssentialAppUIKit

extension ListViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    func simulateTapOnErrorMessage() {
        errorView.simulateTap()
    }

    @discardableResult
    func simulateFeedImageViewVisiable(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }

    @discardableResult
    func simulateFeedImageViewNotVisiable(at row: Int) -> FeedImageCell? {
        let cell = simulateFeedImageViewVisiable(at: row)
        let index = IndexPath(row: row, section: feedImageSection)
        tableView.delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: index)
        return cell
    }

    func simulateFeedImageViewNearVisiable(at row: Int) {
        let index = IndexPath(row: row, section: feedImageSection)

        tableView.prefetchDataSource?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageViewNotNearVisiable(at row: Int) {
        simulateFeedImageViewNearVisiable(at: row)
        let indexPath = IndexPath(row: row, section: feedImageSection)
        tableView.prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    func numberOfRenderedFeedImageView() -> Int {
        tableView.numberOfSections == 0 ? 0 :
        tableView.numberOfRows(inSection: feedImageSection)
    }

    func simulateTapOnFeedImage(at row: Int) {
        let ds = tableView.delegate
        ds?.tableView?(tableView, didSelectRowAt: IndexPath(row: row, section: feedImageSection))
    }

    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }

    func simulateLoadMoreFeedAction() {
        if numberOfRows(in: feedLoadMoreSection) == 0 {
            //prevent indexPath doesn’t exist in the data source
            //loadMoreCell in section doesn't exist
            //Invalid parameter not satisfying: itemIdentifier (NSInternalInconsistencyException)
            return
        }
        let ds = tableView.dataSource
        let indexPathForLoadMoreCell = IndexPath(row: 0, section: feedLoadMoreSection)
        guard let view = ds?.tableView(tableView, cellForRowAt: indexPathForLoadMoreCell) as? LoadMoreCell else { return }

        let dl = tableView.delegate
        dl?.tableView?(tableView, willDisplay: view, forRowAt: indexPathForLoadMoreCell)
    }

    func simulateTapOnLoadMoreErrorView() {
        let loadMoreCellIndexPath = IndexPath(row: 0, section: feedLoadMoreSection)
        let dl = tableView.delegate
        dl?.tableView?(tableView, didSelectRowAt: loadMoreCellIndexPath)
    }

    func loadMoreFeedErrorViewIsVisible() -> Bool {
        return loadMoreFeedCell()?.message != nil
    }

    private func loadMoreFeedCell() -> LoadMoreCell? {
        if numberOfRows(in: feedLoadMoreSection) == 0 {
            return nil
        }
        let ds = tableView.dataSource
        let indexPathForLoadMoreCell = IndexPath(row: 0, section: feedLoadMoreSection)
        return ds?.tableView(tableView, cellForRowAt: indexPathForLoadMoreCell) as? LoadMoreCell
    }

    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }

    var isShowingLoadMoreFeedIndicator: Bool {
        return loadMoreFeedCell()?.isLoading == true
    }

    private var feedLoadMoreSection: Int {
        1
    }

    func canLoadMoreFeed() -> Bool {
        loadMoreFeedCell() != nil
    }
}

extension ListViewController {

    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageView() > row else {return nil}
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }

    private var feedImageSection: Int {
        0
    }

    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisiable(at: index)?.renderedImage
    }
}

extension ListViewController {
    func numberOfRenderedComments() -> Int {
        tableView.numberOfSections == 0 ? 0 :
        tableView.numberOfRows(inSection: commentsSection)
    }

    private var commentsSection: Int { 0 }

    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }

    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }

    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }

    private func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedFeedImageView() > row else {return nil}
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }
}
extension FeedImageCell {
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }

    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }

    var locationText: String? {
        locationLabel.text
    }

    var descriptionText: String? {
        descripitonLabel.text
    }

    var isShowingImageIndicator: Bool {
        feedimageContainer.isShimmering
    }

    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }

    var isShowingRetryAction: Bool {
        !feedImageRetryButton.isHidden
    }
}

extension UIButton {
    func simulateTap() {
//        sendActions(for: .touchUpInside)
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({ (selector) in
                let selector1 = Selector(selector)
                (target as NSObject).perform(selector1)
            })
        })

    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ (target) in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ (selector) in
                (target as NSObject).perform(Selector(selector))
            })
        })
    }
}

extension UIImage {
    static func make(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
