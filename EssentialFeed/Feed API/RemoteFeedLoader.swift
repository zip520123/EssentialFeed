//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by zip520123 on 18/08/2021.
//

import Foundation
public protocol HTTPClient {
    func get(from url: URL)
    
}
public struct RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load() {
        client.get(from: url)
    }
}
