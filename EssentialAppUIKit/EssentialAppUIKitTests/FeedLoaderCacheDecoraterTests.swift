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
        let loader = LoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorater(decoratee: loader)

        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversFeedOnLoaderFailure() {

        let loader = LoaderStub(result: .failure(anyNSError()))
        let sut = FeedLoaderCacheDecorater(decoratee: loader)

        expect(sut, toCompleteWith: .failure(anyNSError()))
    }

}
