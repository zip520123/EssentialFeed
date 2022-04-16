//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
public final class ErrorView: UIButton {

	public var message: String? {
		get { return isVisible ? title(for: .normal) : nil }
	}

	public var isVisible: Bool {
		return alpha > 0
	}

    public var onHide: (()->())?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func hideMsg() {
        setTitle(nil, for: .normal)
        alpha = 0
        contentEdgeInsets = .init(top: -2.5, left: 0, bottom: -2.5, right: 0)
        onHide?()
    }

    private func configure() {
        backgroundColor = UIColor.errorBackgroundColor
        addTarget(self, action: #selector(hideMessageAnimate), for: .touchUpInside)
        configureLabel()
        hideMsg()
    }

    private func configureLabel() {
        titleLabel?.textColor = .white
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 0
        titleLabel?.font = .systemFont(ofSize: 17)
    }

	func show(message: String) {
		setTitle(message, for: .normal)
        contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)

		UIView.animate(withDuration: 0.25) {
			self.alpha = 1
		}
	}

	@objc private func hideMessageAnimate() {
		UIView.animate(
			withDuration: 0.25,
			animations: { self.alpha = 0 },
			completion: { [weak self] completed in
				if completed {
                    self?.hideMsg()
				}
			})
	}
}

extension ErrorView: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
		if let msg = viewModel.errorMessage {
			show(message: msg)
		} else {
			hideMessageAnimate()
		}
	}
}

extension UIColor {
    static var errorBackgroundColor: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
