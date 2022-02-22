import XCTest
import EssentialFeed

class RemoteImageDataLoader {
    let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url, completion: {result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            default:
                break
            }
        })
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
        sut.loadImageData(from: url,completion: {_ in})
        XCTAssertEqual(client.requests, [url])
    }

    func test_loadImageTwice() {
        let (client, sut) = makeSUT()
        let url = anyURL()
        sut.loadImageData(from: url,completion: {_ in})
        sut.loadImageData(from: url,completion: {_ in})
        XCTAssertEqual(client.requests, [url, url])
    }

    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        let error = NSError(domain: "a client error", code: 0)
        expect(sut, toCompleteWith: .failure(error)) {
            client.complete(with: error)
        }
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (HTTPClientSpy, RemoteImageDataLoader) {
        let spy = HTTPClientSpy()
        let sut = RemoteImageDataLoader(client: spy)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (spy, sut)
    }
    private class HTTPClientSpy: HTTPClient {
        private var msgs = [(URL, (HTTPClient.Result) -> Void)]()
        var requests: [URL] {
            msgs.map{$0.0}
        }
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            msgs.append((url,completion))
        }

        func complete(with error: Error, at index: Int = 0){
            msgs[index].1(.failure(error))
        }
    }

    private func expect(_ sut: RemoteImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: ()->(), file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "wait for load complete")
        sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {

            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData, file: file, line: line)

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
