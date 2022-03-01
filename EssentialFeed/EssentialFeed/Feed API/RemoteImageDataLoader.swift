
public final class RemoteImageDataLoader: FeedImageDataLoader {
    let client: HTTPClient
    public init(client: HTTPClient) {
        self.client = client
    }

    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        var httpClientTask: HTTPClientTask?
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        init(completion: @escaping ((FeedImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }

        func cancel() {
            httpClientTask?.cancel()
            completion = nil
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

    }

    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion: completion)
        task.httpClientTask = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result.mapError { _ in
                Error.connectivity
            }.flatMap({ data, res in
                let isValidRes = res.statusCode == 200 && !data.isEmpty
                return isValidRes ? .success(data) : .failure(Error.invalidData)
            }))
        })
        return task
    }

    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
}
