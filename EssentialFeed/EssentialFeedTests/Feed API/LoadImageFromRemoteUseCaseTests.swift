import XCTest
import EssentialFeed

class RemoteImageDataLoader {

}

class LoadImageFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (client, _) = makeSUT()
        XCTAssertEqual(client.requests, [])

    }

    private func makeSUT() -> (HTTPClientSpy, RemoteImageDataLoader) {

        return (HTTPClientSpy(), RemoteImageDataLoader())
    }
    private class HTTPClientSpy {
        var requests = [URL]()
    }

}
