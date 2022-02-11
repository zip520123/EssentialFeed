//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
public final class ErrorView: UIView {
	@IBOutlet private(set) public var button: UIButton!

	public var message: String? {
		get { return isVisible ? button.title(for: .normal) : nil }
	}

	public var isVisible: Bool {
		return alpha > 0
	}

	public override func awakeFromNib() {
		super.awakeFromNib()

		button.setTitle(nil, for: .normal)
		alpha = 0
	}

	func show(message: String) {
		button.setTitle(message, for: .normal)

		UIView.animate(withDuration: 0.25) {
			self.alpha = 1
		}
	}

	@IBAction func hideMessage() {
		UIView.animate(
			withDuration: 0.25,
			animations: { self.alpha = 0 },
			completion: { completed in
				if completed {
					self.button.setTitle(nil, for: .normal)
				}
			})
	}
}

extension ErrorView: FeedErrorView {
    public func display(_ viewModel: FeedErrorViewModel) {
		if let msg = viewModel.errorMessage {
			show(message: msg)
		} else {
			hideMessage()
		}
	}
}


