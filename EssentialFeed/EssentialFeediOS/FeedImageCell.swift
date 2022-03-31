//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 04/11/2021.
//

import UIKit

public class FeedImageCell: UITableViewCell {

    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descripitonLabel: UILabel!
    @IBOutlet private(set) public var feedimageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
    
    public var onRetry: (()->())?
    
    @IBAction func retryButtonTapped() {
        onRetry?()
    }
}
