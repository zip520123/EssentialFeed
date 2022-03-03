//
public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult)->())
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

public class LocalFeedImageDataLoader: FeedImageDataLoader {
    private class LoadImageDataTask: FeedImageDataLoaderTask {
        var completion: ((FeedImageDataLoader.Result) -> ())?

        func cancel() {
            completion = nil
        }
    }

    let store: FeedImageDataStore
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask()
        task.completion = completion
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data):
                if data == nil {
                    task.completion?(.failure(LoadError.notFound))
                } else {
                    task.completion?(.success(data!))
                }

            case .failure:
                task.completion?(.failure(LoadError.failed))
            }

        }
        return task
    }

    public func save(_ data: Data, for url: URL) {
        store.insert(data, for: url) { result in
        }
    }

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
}
