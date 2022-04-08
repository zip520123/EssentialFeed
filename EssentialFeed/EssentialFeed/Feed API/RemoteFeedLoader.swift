//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by zip520123 on 18/08/2021.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        _ = client.get(from: url) {[weak self] result in
            guard self != nil else {return}
            switch result {
            case let .success((data, response)):
                completion(RemoteFeedLoader.map(data, response))
                
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
    
}



