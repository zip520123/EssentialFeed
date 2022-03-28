import EssentialFeed
public class FeedImageDataLoaderCacheDecorater: FeedImageDataLoader {
    let decoratee: FeedImageDataLoader
    let cache: ImageDataCacheLoader
    public init(decoratee: FeedImageDataLoader, cache: ImageDataCacheLoader) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result)->Void ) -> FeedImageDataLoaderTask {
        let task = decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.save(data, for: url, completion: { res in

                })
            }
            completion(result)
        }
        return task
    }
}
