//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by zip520123 on 17/09/2021.
//

import Foundation
struct FeedCachePolicy {
    private init() {}
    
    private static let maxCacheAgeInDays = 7
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: FeedCachePolicy.maxCacheAgeInDays, to: timestamp) else {return false}
        return maxCacheAge > date
    }
    
}
