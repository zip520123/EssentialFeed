import EssentialFeed
public class FeedImageDataLoaderCacheDecorater: FeedImageDataLoader {
    let decoratee: FeedImageDataLoader
    let cache: ImageDataCacheLoader
    public init(decoratee: FeedImageDataLoader, cache: ImageDataCacheLoader) {
        self.decoratee = decoratee
        self.cache = cache
    }

    class Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result)->Void ) -> FeedImageDataLoaderTask {
        let _ = decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.saveImage(data, for: url)
            }
            completion(result)
        }
        return Task()
    }
}
