import EssentialFeed

public final class FeedLoaderCacheDecorater: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.cache.save(feed, completion: { _ in })
            default:
                break
            }
            completion(result)
        }
    }
}
