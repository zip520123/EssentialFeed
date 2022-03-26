import XCTest
import EssentialFeed

class FeedImageDataLoaderCacheDecorater: FeedImageDataLoader {
    let decoratee: FeedImageDataLoader
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }

    class Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result)->Void ) -> FeedImageDataLoaderTask {
        let _ = decoratee.loadImageData(from: url) { result in
            completion(result)
        }
        return Task()
    }
}

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

    private func makeSUT(result: FeedImageDataLoader.Result) -> FeedImageDataLoaderCacheDecorater {
        let stub = ImageDataLoaderStub(result: result)
        let sut = FeedImageDataLoaderCacheDecorater(decoratee: stub)
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
