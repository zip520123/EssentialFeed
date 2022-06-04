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
        _ = try? sut.loadImageData(from: url)
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

    private func notFound() -> Result<Data, Error> {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }

    private func failed() -> Result<Data, Error> {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }

    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Data, Error>, when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        action()

        let result = Result {try sut.loadImageData(from: anyURL())}

        switch (result, expectedResult) {
        case let (.success(data), .success(expectedData)):
            XCTAssertEqual(data, expectedData, file: file, line: line)
        case (.failure(let error as LocalFeedImageDataLoader.LoadError), .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
            XCTAssertEqual(error, expectedError, file: file, line: line)
        default:
            XCTFail("Expected result \(expectedResult), got \(result) instead", file: file, line: line)
        }

    }


    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let loader = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(loader)
        return (loader, store)
    }

}
