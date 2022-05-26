//
import UIKit
import EssentialFeed

public class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let cell = LoadMoreCell()
    private let callBack: ()->()

    public init(callBack: @escaping () -> () = {}) {
        self.callBack = callBack
        cell.selectionStyle = .none
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }

    public func tableView(_ tableView: UITableView, willDisplay: UITableViewCell, forRowAt indexPath: IndexPath) {
        reloadIfNeed()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reloadIfNeed()
    }

    private func reloadIfNeed() {
        guard !cell.isLoading else { return }
        callBack()
    }
}

extension LoadMoreCellController: ResourceLoadingView, ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell.message = viewModel.errorMessage
    }

    public func display(viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}
