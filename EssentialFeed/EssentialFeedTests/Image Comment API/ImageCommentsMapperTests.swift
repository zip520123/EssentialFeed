import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon2XXHTTPResponse() throws {
        let json = makeItemsJSON([])

        let smaple = [199, 150, 300, 400, 500]
        try smaple.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn2XXHTTPResponseWithInvalidJSON() throws {

        let smaple = [200, 201, 250, 280, 299]
        let invalidJSON = Data("InvalidJSON".utf8)
        try smaple.forEach { code in
                XCTAssertThrowsError(
                    try ImageCommentsMapper.map(invalidJSON, HTTPURLResponse(statusCode: code))
                )
            }
    }


    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {

        let emptyListJSON = makeItemsJSON([])
        let smaple = [200, 201, 250, 280, 299]
        try smaple.forEach { code in
            let res = try ImageCommentsMapper.map(emptyListJSON, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(res, [])
        }

    }

    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
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
        let json = makeItemsJSON([item1.json, item2.json])

        try smaple.forEach { code in
            let res = try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(res, items)

        }

    }

    //MARK: - Helpers

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

}
