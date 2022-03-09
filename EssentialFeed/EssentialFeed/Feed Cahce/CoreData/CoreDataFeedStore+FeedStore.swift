import CoreData

extension CoreDataFeedStore: FeedStore {
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { (context) in
            completion(Result {
                try Cache.find(in: context).map { cache in
                    CacheFeed(feed: cache.localFeeds, timestamp: cache.timestamp)
                }
            })

        }
    }

    public func insert(_ feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let cache = try Cache.newUniqueInstance(in: context)

                cache.timestamp = timestamp
                cache.feeds = Feed.feeds(from: feeds, context)

                try context.save()

                completion(.success(()))
            } catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { (context) in
            do {
                if let cache = try Cache.find(in: context) {
                    context.delete(cache)
                    try context.save()
                }
                completion(.success(()))
            } catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }
}
