//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 16/09/2021.
//

import EssentialFeed

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
}

func uniqueImageFeed() -> (models:[FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    return (models, local)
}


    
extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)!
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -7)
    }
}
