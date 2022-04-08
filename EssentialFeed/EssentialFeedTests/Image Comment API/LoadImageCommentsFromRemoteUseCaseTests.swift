import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {


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
            message: "a message",
            createAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "Alex"
        )

        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username")

        let items = [item1.model, item2.model]

        let smaple = [200, 201, 250, 280, 299]
        smaple.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: .success(items), when: {
                let json = makeItemsJSON([item1.json, item2.json])
                client.complete(status: code, data: json, at: index)
            })
        }

    }

    //MARK: - Helpers


    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }


    private func makeItem(id: UUID, message: String, createAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createAt: createAt.date, username: username)
        let json: [String: Any] = [
            "id" : id.uuidString,
            "message": message,
            "created_at": createAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
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
