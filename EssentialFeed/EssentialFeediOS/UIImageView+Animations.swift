//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 20/12/2021.
//

import UIKit

public extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        guard image != nil else {return}
        alpha = 0
        UIView.animate(withDuration: 1) { [weak self] in
            self?.alpha = 1
        }
        
    }
}
