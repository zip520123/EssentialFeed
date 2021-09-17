//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by zip520123 on 13/09/2021.
//

import Foundation
private class FeedCachePolicy {

    private let currentDate: ()->Date
    private let maxCacheAgeInDays = 7
    
    internal init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {return false}
        return maxCacheAge > currentDate()
    }
    
}

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: ()->Date
    private let cachePolicy: FeedCachePolicy
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.cachePolicy = FeedCachePolicy(currentDate: currentDate)
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
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
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult)->Void) {
        store.insert(feed.toLocal(), timestamp: currentDate(), completion: { [weak self] error in
            if self != nil {
                completion(error)
            }
        })
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult
    
    public func load(completion: @escaping (LoadResult)->Void ) {
        store.retrieve(completion: { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            
            case .found(let images, let timestamp) where self.cachePolicy.validate(timestamp):
                completion(.success(images.toModel()))
            case .found, .empty:
                completion(.success([]))
            }
        })
    }
    
    public func validateCache() {
        store.retrieve(completion: {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .found(_, let timestamp) where !self.cachePolicy.validate(timestamp):
                self.store.deleteCachedFeed(completion: {_ in })
            case .failure:
                self.store.deleteCachedFeed(completion: {_ in })
            case .empty, .found:
                break
            }
        })
        
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}

