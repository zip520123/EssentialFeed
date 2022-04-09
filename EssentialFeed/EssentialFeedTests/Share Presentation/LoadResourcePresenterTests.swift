//

import XCTest
import EssentialFeed

class LoadResourcePresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.msg.isEmpty)
    }

    func test_didStartLoading_displaysNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoading()

        XCTAssertEqual(view.msg, [
            .error(msg: nil),
            .loading(isLoading: true)
        ])
    }

    func test_didFinishLoadingResource_displaysResourceAndStopsLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
            resource + " view model"
        })

        sut.didFinishLoading(with: "resource")

        XCTAssertEqual(view.msg, [
            .display(resourceViewModel: "resource view model"),
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

    private func makeSUT(
        mapper: @escaping (String) -> String = { _ in "any" },
        file: StaticString = #file,
        line: UInt = #line) -> (sut: LoadResourcePresenter, view: ViewSpy) {
        let view = ViewSpy()
            let sut = LoadResourcePresenter(feedErrorView: view, loadingView: view, resourceView: view, mapper: mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)

    }

    private class ViewSpy: FeedErrorView, FeedLoadingView, ResourceView {

        enum Message: Hashable {
            case error(msg: String?)
            case loading(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        private(set) var msg = Set<Message>()
        func display(_ viewModel: FeedErrorViewModel) {
            msg.insert(.error(msg: viewModel.errorMessage))
        }
        func display(viewModel: FeedLoadingViewModel) {
            msg.insert(.loading(isLoading: viewModel.isLoading))
        }
        func display(_ viewModel: String) {
            msg.insert(.display(resourceViewModel: viewModel))
        }
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
