//

import Foundation
extension CoreDataFeedStore: FeedImageDataStore {

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

}
