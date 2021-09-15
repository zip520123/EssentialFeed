//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 15/09/2021.
//

import XCTest
import EssentialFeed
class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteMessageUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load {_ in}
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        let retrievalError = anyNSError()
        var retrievedError: Error?
        sut.load { result in
            switch result {
            
            case .failure(let error):
                retrievedError = error
            default:
                XCTFail("expect error, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(retrievalError, retrievedError as NSError?)
    }

    // MARK: - Helper
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}




