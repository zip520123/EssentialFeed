import XCTest
import EssentialFeed

class RemoteImageDataLoader {
    let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url, completion: {_ in})
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

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (HTTPClientSpy, RemoteImageDataLoader) {
        let spy = HTTPClientSpy()
        let sut = RemoteImageDataLoader(client: spy)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (spy, sut)
    }
    private class HTTPClientSpy: HTTPClient {
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requests.append(url)
        }

        var requests = [URL]()
    }

}
