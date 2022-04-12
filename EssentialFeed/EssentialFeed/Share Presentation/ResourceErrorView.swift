
public protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}

public struct ResourceErrorViewModel {
    public let errorMessage: String?
    public init(errorMessage: String?) {
        self.errorMessage = errorMessage
    }
}

extension ResourceErrorViewModel: Equatable {
}
