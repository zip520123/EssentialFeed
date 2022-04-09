//

import XCTest
import EssentialFeed

class LoadResourcePresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.msg.isEmpty)
    }

    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()

        XCTAssertEqual(view.msg, [
            .error(msg: nil),
            .loading(isLoading: true)
        ])

    }

    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed().models
        sut.didFinishLoadingFeed(with: feed)

        XCTAssertEqual(view.msg, [
            .display(feed: feed),
            .loading(isLoading: false)
        ])

    }

    func test_finishedLoadingFeed_displayErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        let error = anyNSError()
        sut.didFinishLoadingFeed(with: error)

        XCTAssertEqual(view.msg, [
            .error(msg: localized("FEED_VIEW_CONNECTION_ERROR") ),
            .loading(isLoading: false)
        ])
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LoadResourcePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = LoadResourcePresenter(feedErrorView: view, loadingView: view, feedView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)

    }

    func localized(_ key: String, _ file: StaticString = #file, _ line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized String for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

}
