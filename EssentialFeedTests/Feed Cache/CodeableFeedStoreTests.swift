//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 19/09/2021.
//

import XCTest
import EssentialFeed


class CodeableFeedStoreTests: XCTestCase, FailableFeedStore {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert(sut, feed, timestamp)
        
        expect(sut, toRetrieveTwice: .found(feed, timestamp))
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        assertRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert(sut, feed, timestamp)
        
        XCTAssertNil(insertionError)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let firstInsertionError = insert(sut, uniqueImageFeed().local, Date())
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        insert(sut, latestFeed, latestTimeStamp)
        
        expect(sut, toRetrieve: .found(latestFeed, latestTimeStamp))
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let firstInsertionError = insert(sut, uniqueImageFeed().local, Date())
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        let latestInsertionError = insert(sut, latestFeed, latestTimeStamp)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert(sut, feed, timestamp)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(sut, feed, timestamp)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        deleteCache(sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliverNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(sut)
        
        XCTAssertNil(deletionError)
    }
    
    func test_delete_emptiesPreivouslyInsertedCache() {
        let sut = makeSUT()
        insert(sut, uniqueImageFeed().local, Date())
        
        deleteCache(sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliverNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert(sut, uniqueImageFeed().local, Date())
        
        let deletionError = deleteCache(sut)
        
        XCTAssertNil(deletionError)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletionPermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletionPermissionURL)
        insert(sut, uniqueImageFeed().local , Date())
        
        let deletionError = deleteCache(sut)
        
        XCTAssertNotNil(deletionError)
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() {
        let noDeletionPermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDeletionPermissionURL)
        insert(sut, uniqueImageFeed().local , Date())
        
        deleteCache(sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffect_runSerially() {
        let sut = makeSUT()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Opertation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date(), completion: {_ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        })
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { (_) in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { (_) in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        XCTAssertEqual([op1,op2,op3], completedOperationsInOrder, "Expected side-effects to run serially but operations finished in the wrong order")
        
    }
    
    // - MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
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
