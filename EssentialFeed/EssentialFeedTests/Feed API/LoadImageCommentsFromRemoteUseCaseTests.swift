import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

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

    func test_load_deliversErrorOnNon2XXHTTPResponse() {
        let (sut, client) = makeSUT()

        let smaple = [199, 150, 300, 400, 500]
        smaple.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: failure(.invalidData) , when: {
                let json = makeItemsJSON([])
                client.complete(status: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversErrorOn2XXHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        let smaple = [200, 201, 250, 280, 299]
        smaple.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: failure(.invalidData), when: {
                let invalidJSON = Data("InvalidJSON".utf8)
                client.complete(status: code, data: invalidJSON, at: index)
            })
        }
    }


    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        let smaple = [200, 201, 250, 280, 299]
        smaple.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: .success([]), when: {
                let emptyListJSON = makeItemsJSON([])
                client.complete(status: code, data: emptyListJSON, at: index)
            })
        }

    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)

        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string:"http://another-url.com")!)

        let items = [item1.model, item2.model]

        let smaple = [200, 201, 250, 280, 299]
        smaple.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: .success(items), when: {
                let json = makeItemsJSON([item1.json, item2.json])
                client.complete(status: code, data: json, at: index)
            })
        }

    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
        var captureResults = [RemoteImageCommentsLoader.Result]()
        sut?.load(completion: {captureResults.append($0)})
        sut = nil
        client.complete(status: 200, data: makeItemsJSON([]))
        XCTAssertTrue(captureResults.isEmpty)
    }

    //MARK: - Helpers


    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
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

    func expect(_ sut: RemoteImageCommentsLoader, toCompleteWithResult expectedResult: RemoteImageCommentsLoader.Result, when action: ()->Void, file: StaticString = #filePath, line: UInt = #line){
        let exp = expectation(description: "wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file:file, line:line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        RemoteImageCommentsLoader.Result.failure(error)
    }

}
