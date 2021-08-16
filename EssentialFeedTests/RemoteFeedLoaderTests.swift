//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 16/08/2021.
//

import XCTest
struct RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    func load() {
        client.get(from: url)
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
        let url = URL(string: "https://a-given-url.com")!
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDateFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        XCTAssertEqual(url, client.requestedURL)
    }
}
