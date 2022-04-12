//

import Foundation
public protocol ResourceLoadingView {
    func display(viewModel: ResourceLoadingViewModel)
}

public struct ResourceLoadingViewModel {
    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }

    public let isLoading: Bool
}
