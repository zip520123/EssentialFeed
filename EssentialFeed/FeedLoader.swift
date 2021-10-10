//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by zip520123 on 12/08/2021.
//

import Foundation
public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult)->Void)
}
