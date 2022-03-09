//

import Foundation
extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> ()) {
        perform { context in
            let res = RetrievalResult { try Feed.first(with: url, in: context)?.data }
            completion(res)
        }
    }

    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        perform { context in

            completion(InsertionResult {
                let image = try Feed.first(with: url, in: context)
                image?.data = data
                try context.save()
            })

        }
    }
}
