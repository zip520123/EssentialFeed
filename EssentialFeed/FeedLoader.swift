//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by zip520123 on 12/08/2021.
//

import Foundation
public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult<Error>)->Void)
}
