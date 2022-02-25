import XCTest
import EssentialFeed

class RemoteImageDataLoader {
    let client: HTTPClient
    init(client: HTTPClient) {
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
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion: completion)
        task.httpClientTask = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, res)):
                if res.statusCode == 200 && !data.isEmpty{
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            case let .failure(error):
                task.complete(with: .failure(error))
            }
        })
        return task
    }

    public enum Error: Swift.Error {
        case invalidData
    }
}

class LoadImageFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (client, _) = makeSUT()
        XCTAssertEqual(client.requests, [])

    }

    func test_loadImageData() {
        let (client, sut) = makeSUT()
        let url = anyURL()
        let _ = sut.loadImageData(from: url,completion: {_ in})
        XCTAssertEqual(client.requests, [url])
    }

    func test_loadImageTwice() {
        let (client, sut) = makeSUT()
        let url = anyURL()
        let _ = sut.loadImageData(from: url,completion: {_ in})
        let _ = sut.loadImageData(from: url,completion: {_ in})
        XCTAssertEqual(client.requests, [url, url])
    }

    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        let error = NSError(domain: "a client error", code: 0)
        expect(sut, toCompleteWith: .failure(error)) {
            client.complete(with: error)
        }
    }



    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (client, sut) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(RemoteImageDataLoader.Error.invalidData), when: {
                client.complete(status: code, data: Data(), at: index)
            })
        }

    }

    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (client, sut) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteImageDataLoader.Error.invalidData), when: {
            let emptyData = Data()
            client.complete(status: 200, data: emptyData)
        })
    }

    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (client, sut) = makeSUT()
        let nonEmptyData = Data("non emptyData".utf8)

        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(status: 200, data: nonEmptyData)
        })
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteImageDataLoader? = RemoteImageDataLoader(client: client)
        var results = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL(), completion: {results.append($0)})
        sut = nil
        client.complete(status: 200, data: Data())
        XCTAssertTrue(results.isEmpty)
    }

    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (client, sut) = makeSUT()
        let url = URL(string: "https://a-given-url.com")!
        let task = sut.loadImageData(from: url, completion: {_ in})
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (client, sut) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { result in
            received.append(result)
        }
        task.cancel()

        client.complete(status: 404, data: Data())
        client.complete(status: 200, data: nonEmptyData)
        client.complete(with: anyNSError())

        XCTAssertTrue(received.isEmpty)
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (HTTPClientSpy, RemoteImageDataLoader) {
        let spy = HTTPClientSpy()
        let sut = RemoteImageDataLoader(client: spy)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (spy, sut)
    }
    private class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            let callback: ()->()
            func cancel() {
                callback()
            }
        }

        private var msgs = [(URL, (HTTPClient.Result) -> Void)]()
        var requests: [URL] {
            msgs.map{$0.0}
        }

        private(set) var cancelledURLs = [URL]()

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            msgs.append((url,completion))
            return Task { [weak self] in self?.cancelledURLs.append(url) }
        }

        func complete(with error: Error, at index: Int = 0){
            msgs[index].1(.failure(error))
        }

        func complete(status code: Int, data: Data, at index: Int = 0) {
            let res = HTTPURLResponse(url: msgs[index].0, statusCode: code, httpVersion: nil, headerFields: nil)!
            msgs[index].1(.success((data, res)))
        }
    }

    private func expect(_ sut: RemoteImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: ()->(), file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "wait for load complete")
        sut.loadImageData(from: url) { result in
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
        action()

        wait(for: [exp], timeout: 1.0)
    }

}
