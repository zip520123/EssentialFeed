//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by zip520123 on 12/08/2021.
//

import Foundation
enum LoadFeedResult {
    case success([FeedItem])
    case fail(Error)
}
protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult)->Void)
}
