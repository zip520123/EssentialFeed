//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by zip520123 on 18/08/2021.
//

import Foundation
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?,HTTPURLResponse?)->Void)
    
}
public struct RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { error, response in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
        }
    }
}
