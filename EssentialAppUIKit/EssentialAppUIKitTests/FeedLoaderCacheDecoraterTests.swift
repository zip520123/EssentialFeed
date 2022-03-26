//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorater: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.cache.save(feed, completion: { _ in })
            default:
                break
            }
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

    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let cache = CacheSpy()
        let sut = makeSUT(result: .success(feed), cache: cache)
        sut.load { _ in }
        XCTAssertEqual(cache.messages, [.save(feed)])
    }

    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(result: .failure(anyNSError()), cache: cache)
        sut.load { _ in }
        XCTAssertTrue(cache.messages.isEmpty)
    }

    private func makeSUT(result: FeedLoader.Result, cache: CacheSpy = CacheSpy(), file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = LoaderStub(result: result)
        let sut = FeedLoaderCacheDecorater(decoratee: loader, cache: cache)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(loader)
        return sut
    }

    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()

        enum Message: Equatable {
            case save([FeedImage])
        }

        func save(_ feed: [FeedImage], completion: @escaping (SaveResult)->Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }

}
