//

import XCTest
import EssentialFeed

class RemoteLoaderTests: XCTestCase {


    func test_init() {

        let (_,client) = makeSUT()

        XCTAssertEqual(client.requests, [])
    }

    func test_load_requestDateFromURL() {
        let url = URL(string: "https://a-given-url.com")!

        let (sut, client) = makeSUT(url: url)

        sut.load {_ in}

        XCTAssertEqual(client.requests, [url])
    }

    func test_loadTwice_requestDateFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!

        let (sut, client) = makeSUT(url: url)

        sut.load{_ in}
        sut.load{_ in}

        XCTAssertEqual(client.requests, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "test", code: 0)
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            client.complete(with: clientError)
        }

    }

    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: {_, _ in throw anyNSError()} )

        expect(sut, toCompleteWithResult: failure(.invalidData), when: {
            client.complete(status: 200, data: anyData())
        })
    }

    func test_load_deliversMappedResource() {
        let resource = "a resource"

        let (sut, client) = makeSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })

        expect(sut, toCompleteWithResult: .success(resource), when: {
            client.complete(status: 200, data: Data(resource.utf8))
        })
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: {_, _ in "any" })
        var captureResults = [RemoteLoader<String>.Result]()
        sut?.load(completion: {captureResults.append($0)})
        sut = nil
        client.complete(status: 200, data: makeItemsJSON([]))
        XCTAssertTrue(captureResults.isEmpty)
    }

    //MARK: - Helpers


    private func makeSUT(
        url: URL = URL(string: "https://a-given-url.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }


    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id" : id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)

    }

    func expect(_ sut: RemoteLoader<String>, toCompleteWithResult expectedResult: RemoteLoader<String>.Result, when action: ()->Void, file: StaticString = #filePath, line: UInt = #line){
        let exp = expectation(description: "wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file:file, line:line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        RemoteLoader<String>.Result.failure(error)
    }

}
