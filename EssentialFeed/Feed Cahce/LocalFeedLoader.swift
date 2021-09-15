//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by zip520123 on 13/09/2021.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: ()->Date
    
    public typealias SaveResult = Error?
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult)->Void = {_ in}) {
        store.deleteCachedFeed {[weak self] error in
            guard let self = self else {return}
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    public func load() {
        store.retrieve()
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult)->Void) {
        store.insert(feed.toLocal(), timestamp: currentDate(), completion: { [weak self] error in
            if self != nil {
                completion(error)
            }
        })
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    }
}
