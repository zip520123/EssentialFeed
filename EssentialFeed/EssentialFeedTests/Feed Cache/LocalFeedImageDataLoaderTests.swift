//LocalFeedImageDataLoaderTests.swift
import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL)
}

class LocalFeedImageDataLoader: FeedImageDataLoader {
    private class Task: FeedImageDataLoaderTask {
        func cancel() {
        }
    }
    let store: FeedImageDataStore
    init(store: FeedImageDataStore) {
        self.store = store
    }
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url)
        return Task()
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        _ = sut.loadImageData(from: url, completion: {_ in})
        XCTAssertEqual(store.receivedMessages, [.retreive(dataFor: url)])
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let loader = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(loader)
        return (loader, store)
    }

    private class FeedStoreSpy: FeedImageDataStore {
        enum Msg: Equatable {
            case retreive(dataFor: URL)
        }
        private(set) var receivedMessages = [Msg]()

        func retrieve(dataForURL url: URL) {
            receivedMessages.append(.retreive(dataFor: url))
        }
    }
}
