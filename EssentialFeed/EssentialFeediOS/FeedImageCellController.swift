//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 15/11/2021.
//
import UIKit

final class FeedImageCellController {
    let vm: FeedImageCellViewModel<UIImage>
    
    init(_ vm: FeedImageCellViewModel<UIImage>) {
        self.vm = vm
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.locationContainer.isHidden = vm.location == nil
        cell.locationLabel.text = vm.location
        cell.descripitonLabel.text = vm.description
        vm.shimmering = { [weak cell] isShimmering in
            if isShimmering {
                cell?.feedimageContainer.startShimmering()
            } else {
                cell?.feedimageContainer.stopShimmering()
            }
        }
        vm.didLoadImage = { [weak cell] image in cell?.feedImageView.image = image }
        vm.shouldHideButton = { [weak cell] shouldHide in cell?.feedImageRetryButton.isHidden = shouldHide }
        
        cell.onRetry = vm.loadImage
        vm.loadImage()
        
        return cell
    }
    
    func preload() {
        vm.preload()
    }
    
    func cancelLoad() {
        vm.cancel()
    }
}
