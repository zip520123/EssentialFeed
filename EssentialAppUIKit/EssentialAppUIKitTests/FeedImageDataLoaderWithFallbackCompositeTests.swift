import XCTest
import EssentialFeed
class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    let primary: FeedImageDataLoader
    let fallback: FeedImageDataLoader
    private class Task: FeedImageDataLoaderTask {
        var wraper: FeedImageDataLoaderTask?
        func cancel() {
            wraper?.cancel()
        }
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task()
        task.wraper = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wraper = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }

}
class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }

    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }

    func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }

        primaryLoader.complete(with: .failure(anyNSError()))

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
    }

    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()

        XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the fallback loader")
    }

    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: .failure(anyNSError()))
        task.cancel()

        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancel URL loading from fallback loader")
    }

    func test_load_deliversPrimaryImageDataOnPrimaryLoaderSuccess() {
        let expectedData = anyData()

        let (sut, primaryLoader, _) = makeSUT()

        expect(sut, toCompeleteWith: .success(expectedData), when: {
            primaryLoader.complete(with: .success(expectedData))
        })

    }



    private func makeSUT() -> (FeedImageDataLoader, LoaderStub, LoaderStub) {
        let primary = LoaderStub()
        let fallback = LoaderStub()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        trackForMemoryLeaks(primary)
        trackForMemoryLeaks(fallback)
        trackForMemoryLeaks(sut)
        return (sut, primary, fallback)
    }

    private func expect(_ sut: FeedImageDataLoader, toCompeleteWith expectedResult: FeedImageDataLoader.Result, when action: ()->(), file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        let _ = sut.loadImageData(from: anyURL()) { result in
            switch (result, expectedResult) {
            case (.success(let data), .success(let expectedData)):
                XCTAssertEqual(data, expectedData, file:file, line: line)
            case let (.failure(error as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(error, expectedError, file:file, line: line)
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }

    private class LoaderStub: FeedImageDataLoader {
        private var requests = [(url: URL, completion: (FeedImageDataLoader.Result) -> ())]()

        var loadedURLs: [URL] {
            requests.map(\.url)
        }

        private(set) var cancelledURLs = [URL]()

        class Task: FeedImageDataLoaderTask {
            let callback: ()->()
            init(cancel callback: @escaping ()->()) {
                self.callback = callback
            }
            func cancel() {
                callback()
            }
        }

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            requests.append((url, completion))

            return Task(cancel: { [weak self] in
                self?.cancelledURLs.append(url)
            })
        }

        func complete(with result: FeedImageDataLoader.Result, at index: Int = 0) {
            requests[index].completion(result)
        }
    }
}
