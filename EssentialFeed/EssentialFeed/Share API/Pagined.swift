
public struct Paginated<Item> {
    public typealias LoadCompletion = (Result<Self, Error>) -> ()
    public let items: [Item]
    public let loadMore: ((@escaping LoadCompletion) -> Void)?

    public init(items: [Item], loadMore: ((@escaping LoadCompletion) -> Void)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}

