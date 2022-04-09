//

import Foundation
public protocol ResourceLoadingView {
    func display(viewModel: ResourceLoadingViewModel)
}

public struct ResourceLoadingViewModel {
    public let isLoading: Bool
}
