//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorater: FeedLoader {
    let decoratee: FeedLoader
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { result in
            completion(result)
        }
    }
}

class FeedLoaderCacheDecoraterTests: XCTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let loader = LoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorater(decoratee: loader)

        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversFeedOnLoaderFailure() {

        let loader = LoaderStub(result: .failure(anyNSError()))
        let sut = FeedLoaderCacheDecorater(decoratee: loader)

        expect(sut, toCompleteWith: .failure(anyNSError()))
    }


    // MARK: - Helpers


    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result) {
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
