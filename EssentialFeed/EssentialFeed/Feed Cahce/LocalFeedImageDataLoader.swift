//
public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
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
