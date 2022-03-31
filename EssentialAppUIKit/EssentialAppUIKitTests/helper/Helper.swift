//
import UIKit
import EssentialFeediOS
import EssentialAppUIKit

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    func simulateTapOnErrorMessage() {
        errorView.button.simulateTap()
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
        tableView.numberOfRows(inSection: feedImageSection)
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
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
