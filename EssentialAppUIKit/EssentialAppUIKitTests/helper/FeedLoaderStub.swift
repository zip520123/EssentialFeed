import EssentialFeed
import XCTest

class LoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

    func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://any-url.com")!)]
    }
}

protocol FeedLoaderTestCase: XCTestCase {}

extension FeedLoaderTestCase {
    func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):

                XCTAssertEqual(receivedFeed, expectedFeed)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected successful load, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
