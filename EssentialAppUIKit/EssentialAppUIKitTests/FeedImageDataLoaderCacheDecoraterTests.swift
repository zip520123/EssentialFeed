import XCTest
import EssentialFeed
import EssentialAppUIKit

class ImageDataLoaderStub: FeedImageDataLoader {
    private let result: FeedImageDataLoader.Result

    class Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    init(result: FeedImageDataLoader.Result) {
        self.result = result
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        completion(result)
        return Task()
    }

}

class FeedImageDataLoaderCacheDecoraterTests: XCTestCase {
    func test_load_deliversImageDataOnLoaderSuccess() {
        let imageData = Data()
        let sut = makeSUT(result: .success(imageData))
        let _ = sut.loadImageData(from: anyURL(), completion: { _ in })
        expect(sut, toCompleteWith: .success(imageData))
    }

    func test_load_deliversImageDataOnLoaderFailure() {
        let sut = makeSUT(result: .failure(anyNSError()))
        let _ = sut.loadImageData(from: anyURL(), completion: { _ in })
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }

    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let imageData = Data()
        let cache = CacheSpy()
        let sut = makeSUT(result: .success(imageData), cache: cache)
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(cache.messages, [.save(data: imageData, url: url)])

    }

    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(result: .failure(anyNSError()), cache: cache)
        _ = sut.loadImageData(from: anyURL()) { _ in }
        XCTAssertTrue(cache.messages.isEmpty)
    }

    private class CacheSpy: ImageDataCacheLoader {
        var messages = [Msg]()
        enum Msg: Equatable {
            case save(data: Data, url: URL)
        }

        func save(_ data: Data, for url: URL, completion: @escaping (LocalFeedImageDataLoader.SaveResult) -> Void) {
            messages.append(.save(data: data, url: url))
        }
    }


    private func makeSUT(result: FeedImageDataLoader.Result, cache: CacheSpy = CacheSpy()) -> FeedImageDataLoaderCacheDecorater {
        let stub = ImageDataLoaderStub(result: result)
        let sut = FeedImageDataLoaderCacheDecorater(decoratee: stub, cache: cache)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(stub)
        return sut
    }

    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "wait for load complete")
        _ = sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {

            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData, file: file, line: line)

            case let (.failure(error as RemoteImageDataLoader.Error), (.failure(expectedError as RemoteImageDataLoader.Error))):
                XCTAssertEqual(error, expectedError, file: file, line: line)

            case let (.failure(error as NSError), (.failure(expectedError as NSError))):
                XCTAssertEqual(error, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
