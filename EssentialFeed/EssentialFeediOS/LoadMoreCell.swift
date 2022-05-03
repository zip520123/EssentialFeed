//

import UIKit

public class LoadMoreCell: UITableViewCell {
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        spinner.heightAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true
        return spinner
    }()
    public var isLoading: Bool {
        get {
            spinner.isAnimating
        }
        set {
            newValue ? spinner.startAnimating() : spinner.stopAnimating()
        }
    }
}
