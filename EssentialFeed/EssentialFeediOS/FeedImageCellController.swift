//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 15/11/2021.
//
import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
    
}

final public class FeedImageCellController: NSObject {

    public typealias ResourceViewModel = UIImage
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    private let vm: FeedImageCellViewModel
    public init(viewModel: FeedImageCellViewModel, delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        self.vm = viewModel
    }
}
extension FeedImageCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueCell()
        cell?.locationContainer.isHidden = vm.location == nil
        cell?.locationLabel.text = vm.location
        cell?.descripitonLabel.text = vm.description
        cell?.onRetry = delegate.didRequestImage
        delegate.didRequestImage()
        return cell!
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestImage()
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }

    private func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }

    fileprivate func releaseCellForReuse() {
        cell = nil
    }

}

extension FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }

    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.errorMessage == nil
    }

    public func display(viewModel: ResourceLoadingViewModel) {
        viewModel.isLoading ? cell?.feedimageContainer.startShimmering() : cell?.feedimageContainer.stopShimmering()
    }

}
