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

final public class FeedImageCellController: FeedImageView, ResourceView, ResourceLoadingView, ResourceErrorView {
    public typealias ResourceViewModel = UIImage
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    private let vm: FeedImageCellViewModel<UIImage>
    public init(viewModel: FeedImageCellViewModel<UIImage>, delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        self.vm = viewModel
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueCell()
        cell?.locationContainer.isHidden = vm.location == nil
        cell?.locationLabel.text = vm.location
        cell?.descripitonLabel.text = vm.description
        cell?.onRetry = delegate.didRequestImage
        delegate.didRequestImage()

        return cell!
    }
    
    public func display(_ vm: FeedImageCellViewModel<UIImage>) {
    }

    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }

    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.errorMessage == nil
    }

    public func display(viewModel: ResourceLoadingViewModel) {
        viewModel.isLoading ? cell?.feedimageContainer.startShimmering() : cell?.feedimageContainer.stopShimmering()
    }


    func preload() {
        delegate.didRequestImage()
    }
    
    fileprivate func releaseCellForReuse() {
        cell = nil
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
}
