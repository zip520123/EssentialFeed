//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 21/09/2021.
//

import XCTest
import EssentialFeed


class CoreDataFeedStoreTests: XCTestCase, FailableFeedStore {
    func test_retrieve_deliverEmptyOnEmptyCache() throws {
        let sut = try makeSUT()
        assertRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()
        assertRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() throws {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()
        
        let sut = try makeSUT()
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectOnFailure() throws {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()
        
        let sut = try makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()
        
        let sut = try makeSUT()
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()
        
        let sut = try makeSUT()
        
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        let sut = try makeSUT()
        
        insert(sut, feed.local, timestamp)
        
        stub.startIntercepting()
        
        let deletionError = deleteCache(sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let sut = try makeSUT()
        
        insert(sut, feed, timestamp)
        
        stub.startIntercepting()
        
        deleteCache(sut)
        
        expect(sut, toRetrieve: .found(feed, timestamp))
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        let sut = try makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliverNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreivouslyInsertedCache() throws {
        let sut = try makeSUT()
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_deliverNoErrorOnNonEmptyCache() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let sut = try makeSUT()
        
        insert(sut, feed, timestamp)
        
        stub.startIntercepting()
        
        let deletionError = deleteCache(sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_storeSideEffect_runSerially() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let sut = try makeSUT()
        
        insert(sut, feed, timestamp)
        
        stub.startIntercepting()
        
        deleteCache(sut)
        
        expect(sut, toRetrieve: .found(feed, timestamp))
    }
    

    
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> FeedStore {
        let inMemoryStoreURL = URL(fileURLWithPath: "/dev/null") // null device discards all data written to it, but reports that the write opreation succeeded, but CoreData still works with the in-memory object graph
        
        let sut = try CoreDataFeedStore(storeURL: inMemoryStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
