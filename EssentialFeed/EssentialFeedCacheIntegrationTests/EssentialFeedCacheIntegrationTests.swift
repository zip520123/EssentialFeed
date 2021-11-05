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
       expect(sut, toLoad: [])
    }

    func test_load_deliversItemsSavedOnSeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(sutToPerformSave, with: feed)
        
        expect(sutToPerformLoad, toLoad: feed)
        
    }

    func test_save_overridesItemsSavedOnSeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let lastFeed = uniqueImageFeed().models
        
        save(sutToPerformFirstSave, with: firstFeed)
        
        save(sutToPerformLastSave, with: lastFeed)
        
        expect(sutToPerformLoad, toLoad: lastFeed)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let store = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func save(_ sut: LocalFeedLoader, with feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(feed) { result in
            switch result {
            case .failure(let error):
                XCTFail("Expected save success, got \(error) instead", file: file, line: line)
            default:
                break
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1)
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let loadExp = expectation(description: "Wait for load completion")
        sut.load { (result) in
            switch result {
            case .success(let resultFeed):
                XCTAssertEqual(resultFeed, expectedFeed, file: file, line: line)
            case .failure(let error):
                XCTFail("Expected load success, got \(error) instead", file: file, line: line)
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1)
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