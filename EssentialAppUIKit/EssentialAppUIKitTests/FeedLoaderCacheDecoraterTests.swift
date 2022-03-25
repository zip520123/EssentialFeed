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

class FeedLoaderCacheDecoraterTests: XCTestCase, FeedLoaderTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(result: .success(feed))

        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversFeedOnLoaderFailure() {
        let sut = makeSUT(result: .failure(anyNSError()))

        expect(sut, toCompleteWith: .failure(anyNSError()))
    }

    private func makeSUT(result: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = LoaderStub(result: result)
        let sut = FeedLoaderCacheDecorater(decoratee: loader)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(loader)
        return sut
    }

}
