import XCTest
import EssentialFeed

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
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

    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError()
            store.complete(with: retrievalError)
        })
    }

    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: notFound(), when: {
            store.complete(with: .none)
        })
    }

    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        expect(sut, toCompleteWith: .success(foundData), when: {
            store.complete(with: foundData)
        })
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        store.complete(with: foundData)
        store.complete(with: .none)
        store.complete(with: anyNSError())

        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")

    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)

        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { received.append($0) }

        sut = nil
        store.complete(with: anyData())

        XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
    }

    private func notFound() -> FeedImageDataLoader.Result {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }

    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }

    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        _ = sut.loadImageData(from: anyURL()) { result in
            switch (result, expectedResult) {
            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData, file: file, line: line)
            case (.failure(let error as LocalFeedImageDataLoader.LoadError), .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(result) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }


    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let loader = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(loader)
        return (loader, store)
    }

}
