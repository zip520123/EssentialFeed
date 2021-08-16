//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 16/08/2021.
//

import XCTest
struct RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}
class HTTPClient {
    static var shared = HTTPClient()
    func get(from url: URL) {}
    
}

class HTTPClientSpy: HTTPClient {
    override func get(from url: URL) {
        requestedURL = url
    }
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDateFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}
