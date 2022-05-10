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

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true

        return label
    }()

    public var isLoading: Bool {
        get {
            spinner.isAnimating
        }
        set {
            newValue ? spinner.startAnimating() : spinner.stopAnimating()
        }
    }

    public var message: String? {
        get {
            messageLabel.text
        }
        set {
            messageLabel.text = newValue
        }
    }
}
