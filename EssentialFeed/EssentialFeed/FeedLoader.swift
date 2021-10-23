//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by zip520123 on 12/08/2021.
//

import Foundation


public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result)->Void)
}
