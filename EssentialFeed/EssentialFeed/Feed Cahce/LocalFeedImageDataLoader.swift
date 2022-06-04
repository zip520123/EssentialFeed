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

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }

    public enum SaveError: Error {
        case failed
    }

    let store: FeedImageDataStore
    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let data = try store.retrieve(dataForURL: url) {
                return data
            }
        } catch {
            throw LoadError.failed
        }
        throw LoadError.notFound
    }

    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }

}
