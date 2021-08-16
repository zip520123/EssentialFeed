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


class RemoteFeedLoaderTests: XCTestCase {

    func test_init() {
        
        let (_,client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDateFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        XCTAssertEqual(url, client.requestedURL)
    }
    
    
    //MARK: - Helpers


    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        func get(from url: URL) {
            requestedURL = url
        }
        
    }
}
