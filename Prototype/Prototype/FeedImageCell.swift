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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImageView.alpha = 0
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(
            withDuration: 0.25,
            delay: 1.25,
            options: [],
            animations: {
                self.feedImageView.alpha = 1
            }, completion: { completed in
                
            })
    }
}
