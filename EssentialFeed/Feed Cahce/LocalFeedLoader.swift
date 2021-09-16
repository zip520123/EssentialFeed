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
    public typealias LoadResult = LoadFeedResult
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
    
    public func load(completion: @escaping (LoadResult)->Void ) {
        store.retrieve(completion: { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            
            case .found(let images, let timestamp) where self.validate(timestamp):
                completion(.success(images.toModel()))
            case .found:
                completion(.success([]))
            case .empty:
                completion(.success([]))
            }
        })
    }
    
    public func validateCache() {
        store.retrieve(completion: {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .found(_, let timestamp) where !self.validate(timestamp):
                self.store.deleteCachedFeed(completion: {_ in })
            case .failure:
                self.store.deleteCachedFeed(completion: {_ in })
            case .empty, .found:
                break
            }
        })
        
    }
    
    private let maxCacheAgeInDays = 7
    
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {return false}
        return maxCacheAge > currentDate()
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

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}

