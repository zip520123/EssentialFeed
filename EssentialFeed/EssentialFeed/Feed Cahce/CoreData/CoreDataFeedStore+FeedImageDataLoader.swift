//

import Foundation
extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> ()) {
        perform { context in
            let res = RetrievalResult { try Feed.data(for: url, in: context) }
            completion(res)
        }
    }

    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        perform { context in

            completion(InsertionResult {
                try Feed.first(with: url, in: context)
                    .map { $0.data = data }
                    .map { try context.save() }
            })

        }
    }
}
