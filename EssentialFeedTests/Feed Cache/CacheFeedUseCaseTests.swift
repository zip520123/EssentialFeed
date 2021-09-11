//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 11/09/2021.
//

import XCTest
import EssentialFeed
class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    var items = [FeedItem]()
    var insertions = [(items: [FeedItem], timestamp: Date)]()
    typealias DeletionCompletion = (Error?)-> Void
    private var deletionCompletions = [DeletionCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        deleteCachedFeedCallCount += 1
    }
    func completionDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    func completionDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
        
    }
    func insert(_ items: [FeedItem], timestamp: Date) {
        insertions.append((items, timestamp))
        insertCallCount += 1
    }
}
class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: ()->Date
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed {[weak self] error in
            guard let self = self else {return}
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount , 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completionDeletion(with: anyNSError())
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completionDeletionSuccessfully()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completionDeletionSuccessfully()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
        XCTAssertEqual(store.insertCallCount, 1)
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }
    
    // MARK: - Helper
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
}
