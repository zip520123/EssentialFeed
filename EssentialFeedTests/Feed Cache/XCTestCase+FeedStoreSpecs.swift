//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 20/09/2021.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
    
    func assertRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.empty), file: file, line: line)
    }
    
    func assertRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert(sut, feed, timestamp)
        
        expect(sut, toRetrieve: .success(.found(feed, timestamp)), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.empty), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(sut, feed, Date())
        
        expect(sut, toRetrieve: .success(.found(feed, timestamp)), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(sut, feed, timestamp)
        
        expect(sut, toRetrieveTwice: .success(.found(feed, timestamp)), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert(sut, uniqueImageFeed().local,  Date())
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(sut, uniqueImageFeed().local,  Date())
        
        let insertionError = insert(sut, uniqueImageFeed().local,  Date())
        
        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(sut, uniqueImageFeed().local,  Date())
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert(sut, latestFeed,  latestTimestamp)
        
        expect(sut, toRetrieve: .success(.found(latestFeed, latestTimestamp)), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(sut)
        
        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(sut, uniqueImageFeed().local,  Date())
        
        let deletionError = deleteCache(sut)
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(sut, uniqueImageFeed().local,  Date())
        
        deleteCache(sut)
        
        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
    
    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            op3.fulfill()
        }
        
        let op4 = expectation(description: "Operation 4")
        sut.retrieve { _ in
            op4.fulfill()
        }
        
        wait(for: [op1, op2, op3, op4], timeout: 5.0, enforceOrder: true)
    }
    
    @discardableResult
    func insert(_ sut: FeedStore, _ feed: [LocalFeedImage], _ timestamp: Date) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        
        sut.insert(feed, timestamp: timestamp) { (error) in
            XCTAssertNil(insertionError, "Expected feed to be insertion successfully")
            insertionError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(_ sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var deletionError: Error?
        
        sut.deleteCachedFeed(completion: {error in
            deletionError = error
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1)
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expetedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expetedResult, file: file, line: line)
        expect(sut, toRetrieve: expetedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expetedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch (result, expetedResult) {
            case let (.success(.found(resultImage, resultDate)), .success(.found(expectedImage, expetedDate))):
                XCTAssertEqual(resultImage, expectedImage, file: file, line: line)
                XCTAssertEqual(resultDate, expetedDate, file: file, line: line)
            case (.success(.empty), .success(.empty)), (.failure, .failure):
                break
            default:
                XCTFail("expected \(expetedResult), got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
