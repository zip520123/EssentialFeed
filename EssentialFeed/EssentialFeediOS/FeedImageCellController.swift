//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 15/11/2021.
//
import EssentialFeed
import UIKit

final class FeedImageCellController {
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.locationContainer.isHidden = model.location == nil
        cell.locationLabel.text = model.location
        cell.descripitonLabel.text = model.description
        cell.feedimageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: self.model.imageURL) { [weak cell] result in
                let data = (try? result.get())
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = image != nil
                cell?.feedimageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func cancel() {
        task?.cancel()
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.imageURL, completion: { _ in })
    }
    
    deinit {
        task?.cancel()
    }
}
