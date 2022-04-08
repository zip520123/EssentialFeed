//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 16/08/2021.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])

        let smaple = [199, 201, 300, 400, 500]
        try smaple.forEach { code in
            XCTAssertThrowsError(
                try FeedItemMapper.map(json, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {

        let invalidJSON = Data("InvalidJSON".utf8)
        XCTAssertThrowsError(
            try FeedItemMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200))
        )

    }

    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON([])
        let res = try FeedItemMapper.map(emptyListJSON, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(res, [])

    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)

        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string:"http://another-url.com")!)
        
        let items = [item1.model, item2.model]
        let json = makeItemsJSON([item1.json, item2.json])

        let res = try FeedItemMapper.map(json, HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(items, res)
    }
    
    //MARK: - Helpers
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id" : id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
        
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        RemoteFeedLoader.Result.failure(error)
    }
    
}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
