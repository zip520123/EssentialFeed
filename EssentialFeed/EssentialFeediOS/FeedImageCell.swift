//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 04/11/2021.
//

import UIKit

public class FeedImageCell: UITableViewCell {

    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descripitonLabel = UILabel()
    public let feedimageContainer = UIView()
    public let feedImageView = UIImageView()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (()->())?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
