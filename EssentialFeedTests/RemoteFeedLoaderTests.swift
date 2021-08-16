//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 16/08/2021.
//

import XCTest
struct RemoteFeedLoader {
    let client: HTTPClient
    
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}
protocol HTTPClient {
    func get(from url: URL)
    
}

class HTTPClientSpy: HTTPClient {
    func get(from url: URL) {
        requestedURL = url
    }
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init() {
        let client = HTTPClientSpy()
        
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDateFromURL() {
        let client = HTTPClientSpy()
        
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}
