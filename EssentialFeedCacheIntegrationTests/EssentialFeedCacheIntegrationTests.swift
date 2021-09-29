//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by zip520123 on 28/09/2021.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [])
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_load_deliversItemsSavedOnSeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "Wait for save completion")
        sutToPerformSave.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1)
        
        let loadExp = expectation(description: "Wait for load completion")
        sutToPerformLoad.load { (result) in
            switch result {
            case .success(let resultFeed):
                XCTAssertEqual(resultFeed, feed)
            case .failure(let error):
                XCTFail("Expected load success, got \(error) instead")
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1)
        
    }
    
    // - MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let store = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
