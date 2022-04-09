//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

    func test_map_createsViewModel() {
        let now = Date()
        let calender = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createAt: now.adding(days: -5, calander: calender),
                username: "a username"),
            ImageComment(
                id: UUID(),
                message: "another message",
                createAt: now.adding(days: -1, calander: calender),
                username: "another username")
        ]

        let viewModel = ImageCommentsPresenter.map(comments, now, calender, locale)
        XCTAssertEqual(viewModel.comments, [ImageCommentViewModel(
                message: "a message",
                date: "5 days ago",
                username: "a username"
            ),ImageCommentViewModel(
                message: "another message",
                date: "1 day ago",
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
