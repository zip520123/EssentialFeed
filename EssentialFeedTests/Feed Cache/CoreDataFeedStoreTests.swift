//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 21/09/2021.
//

import XCTest
import EssentialFeed
import CoreData

class CoreDataFeedStore: FeedStore {
    
//    private let container: NSPersistentContainer
//    private let context: NSManagedObjectContext
    
    init(storeURL: URL, bundle: Bundle = .main) throws {
//        container = try NSPersistentContainer.load(name: "FeedStore", url: storeURL, bundle: bundle)
//        context = container.newBackgroundContext()
    }
    
    private class CoreDataLocalFeedImage {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        init(_ feed: LocalFeedImage) {
            self.id = feed.id
            self.description = feed.description
            self.location = feed.location
            self.url = feed.url
        }
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
}

extension NSPersistentContainer {
    enum LoadingError: Error {
        case modelNotFound
        case failedToLoadPersistenStores(Error)
    }
    
    static func load(name: String, url: URL, bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else { throw LoadingError.modelNotFound }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores(completionHandler: {loadError = $1})
        try loadError.map { throw LoadingError.failedToLoadPersistenStores($0) }
        
        return container
    }
    
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
//        let sut = makeSUT()
//        let feed = uniqueImageFeed().local
//        let timestamp = Date()
//        insert(sut, feed, timestamp)
//
//        expect(sut, toRetrieveTwice: .found(feed, timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_insert_overridePreviouslyInsertedCachedValues() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_deliverNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_emptiesPreivouslyInsertedCache() {
        
    }
    
    func test_delete_deliverNoErrorOnNonEmptyCache() {
        
    }
    
    func test_storeSideEffect_runSerially() {
        
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null") // null device discards all data written to it, but reports that the write opreation succeeded, but CoreData still works with the in-memory object graph
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
