//

import Foundation
extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> ()) {
        completion(.success(.none))
    }

    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {

    }
}
