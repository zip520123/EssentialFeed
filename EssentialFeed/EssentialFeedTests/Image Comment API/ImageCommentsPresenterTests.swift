//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

    func test_map_createsViewModel() {
        let now = Date()
        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createAt: now.adding(seconds: -5),
                username: "a username"),
            ImageComment(
                id: UUID(),
                message: "another message",
                createAt: now.adding(seconds: -1),
                username: "another username")
        ]

        let viewModel = ImageCommentsPresenter.map(comments)
        XCTAssertEqual(viewModel.comments, [ImageCommentViewModel(
                message: "a message",
                date: "5 seconds ago",
                username: "a username"
            ),ImageCommentViewModel(
                message: "another message",
                date: "1 second ago",
                username: "another username"
            )]
        )
    }

    func localized(_ key: String, _ file: StaticString = #file, _ line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized String for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
