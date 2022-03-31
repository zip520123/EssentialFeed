//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 15/11/2021.
//
import UIKit

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
    
}

final public class FeedImageCellController: FeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    public init(_ delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueCell()
        
        delegate.didRequestImage()
        return cell!
    }
    
    public func display(_ vm: FeedImageCellViewModel<UIImage>) {
        cell?.feedImageView.image = nil
        cell?.feedImageRetryButton.isHidden = true
        cell?.locationContainer.isHidden = vm.location == nil
        cell?.locationLabel.text = vm.location
        cell?.descripitonLabel.text = vm.description
        cell?.onRetry = delegate.didRequestImage
        cell?.feedImageView.setImageAnimated(vm.image)
        
        vm.isLoading ? cell?.feedimageContainer.startShimmering() : cell?.feedimageContainer.stopShimmering()
        
        cell?.feedImageRetryButton.isHidden = !vm.shouldRetry
        
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
