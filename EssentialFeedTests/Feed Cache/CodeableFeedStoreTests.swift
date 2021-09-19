//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 19/09/2021.
//

import XCTest
import EssentialFeed

class CodeableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodeableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = CodeableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodeableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { (firstResult) in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same result, got \(firstResult), \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        
        wait(for: [exp], timeout: 1)
    }
}
