//LocalFeedImageDataLoaderTests.swift
import XCTest
import EssentialFeed


class LocalFeedImageDataLoader {

}

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let loader = LocalFeedImageDataLoader()
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(loader)
        return (loader, store)
    }

    private class FeedStoreSpy {
        let receivedMessages = [Any]()
    }
}
