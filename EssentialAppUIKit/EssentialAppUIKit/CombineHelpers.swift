//

import Combine
import EssentialFeed

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data?, Error>
    func loadImagePublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?

        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data? {
    func caching(to cache: ImageDataCacheLoader, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data!, url)
        }).eraseToAnyPublisher()
    }
}

private extension ImageDataCacheLoader {
    func saveIgnoringResult(_ data: Data, _ url: URL) {
        self.save(data, for: url) { _ in }
    }
}

public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Swift.Error>

    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load)
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}
