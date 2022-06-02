//
public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?

    @available(*, deprecated)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult)->())

    @available(*, deprecated)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

public extension FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {
        let group = DispatchGroup()
        group.enter()
        var insertionResult: InsertionResult!
        insert(data,for: url) { result in
            insertionResult = result
            group.leave()
        }
        group.wait()

        return try insertionResult.get()
    }

    func retrieve(dataForURL url: URL) throws -> Data? {
        let group = DispatchGroup()
        group.enter()
        var retrievalResult: RetrievalResult!
        retrieve(dataForURL: url) { result in
            retrievalResult = result
            group.leave()
        }
        group.wait()

        return try retrievalResult.get()
    }

    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult)->()) {}

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
}

public class LocalFeedImageDataLoader: FeedImageDataLoader, ImageDataCacheLoader {
    public typealias SaveResult = Result<Void, Error>

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }

    public enum SaveError: Error {
        case failed
    }

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

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult)->Void) {
        completion(
            SaveResult {
                try store.insert(data, for: url)
            }.mapError { _ in SaveError.failed}
        )
    }


}
