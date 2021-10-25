//
//  FeedImageCell.swift
//  Prototype
//
//  Created by zip520123 on 25/10/2021.
//

import UIKit

final class FeedImageCell: UITableViewCell {

    @IBOutlet private(set) weak var locationContainer: UIStackView!
    @IBOutlet private(set) weak var locationLabel: UILabel!
    
    @IBOutlet private(set) weak var feedImageView: UIImageView!
    
    @IBOutlet private(set) weak var descriptionLabel: UILabel!
}
