
public protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}

public struct ResourceErrorViewModel {
    public let errorMessage: String?
}

extension ResourceErrorViewModel: Equatable {
}
