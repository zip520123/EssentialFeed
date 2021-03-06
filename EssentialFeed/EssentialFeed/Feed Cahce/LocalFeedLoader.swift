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

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader: FeedCache {
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult)->Void = {_ in}) {
        store.deleteCachedFeed {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success:
                self.cache(feed, with: completion)
            case .failure(let error):
                completion(.failure(error))
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

extension LocalFeedLoader {
    public typealias LoadResult = Swift.Result<[FeedImage], Error>
    
    public func load(completion: @escaping (LoadResult)->Void ) {
        store.retrieve(completion: { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModel()))
                
            case .success(.some), .success(.none):
                completion(.success([]))
            }
        })
    }

    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping ((ValidationResult)->())) {
        store.retrieve(completion: {[weak self] result in
            guard let self = self else {return}
            switch result {
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: completion)
                
            case .failure:
                self.store.deleteCachedFeed(completion: completion)
            case .success:
                completion(.success(()))
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

