//

import Foundation
extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> ()) {
        performAsync { context in
            let res = RetrievalResult { try Feed.data(for: url, in: context) }
            completion(res)
        }
    }

    public func insert(_ data: Data, for url: URL) throws {
        try performSync{ context in
            Result { try Feed.first(with: url, in: context)
                .map { $0.data = data }
                .map { try context.save() }

            }
        }
    }

    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync { context in
            Result { try Feed.data(for: url, in: context) }
        }
    }

    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        performAsync { context in

            completion(InsertionResult {
                try Feed.first(with: url, in: context)
                    .map { $0.data = data }
                    .map { try context.save() }
            })

        }
    }
}
