import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    let primary: FeedImageDataLoader
    let fallback: FeedImageDataLoader
    private class Task: FeedImageDataLoaderTask {
        var wraper: FeedImageDataLoaderTask?
        func cancel() {
            wraper?.cancel()
        }
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task()
        task.wraper = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wraper = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }

}
