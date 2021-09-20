//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by zip520123 on 13/09/2021.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case failure(Error)
    case found([LocalFeedImage], Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?)-> Void
    typealias InsertionCompletion = (Error?)-> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult)-> Void
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to approripate threads, if needed
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to approripate threads, if needed
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to approripate threads, if needed
    func retrieve(completion: @escaping RetrievalCompletion)
}
