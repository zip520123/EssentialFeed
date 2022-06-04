//

import EssentialFeed
class NullStore: FeedStore & FeedImageDataStore  {
    func retrieve(dataForURL url: URL) throws -> Data? {
        return nil
    }

    func insert(_ data: Data, for url: URL) throws {}

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }


}
