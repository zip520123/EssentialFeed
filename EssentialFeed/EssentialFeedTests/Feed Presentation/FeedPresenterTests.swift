import XCTest
import EssentialFeed
protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}
struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedErrorViewModel {
    let errorMessage: String?
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}
struct FeedViewModel {
    let feeds: [FeedImage]
}

final class FeedPresenter {
    let feedErrorView: FeedErrorView
    let loadingView: FeedLoadingView
    let feedView: FeedView

    init(feedErrorView: FeedErrorView, loadingView: FeedLoadingView, feedView: FeedView) {
        self.feedErrorView = feedErrorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    func didStartLoadingFeed() {
        feedErrorView.display(FeedErrorViewModel(errorMessage: nil))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feeds: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
        feedErrorView.display(FeedErrorViewModel(errorMessage: FeedPresenter.feedLoadError))
    }


    static var feedLoadError: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")

    }

    static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")
    }
}
class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.msg.isEmpty)
    }

    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
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

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view, loadingView: view, feedView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)

    }

    func localized(_ key: String, _ file: StaticString = #file, _ line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized String for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {

    enum Message: Hashable {
        case error(msg: String?)
        case loading(isLoading: Bool)
        case display(feed: [FeedImage])
    }
    private(set) var msg = Set<Message>()
    func display(_ viewModel: FeedErrorViewModel) {
        msg.insert(.error(msg: viewModel.errorMessage))
    }
    func display(viewModel: FeedLoadingViewModel) {
        msg.insert(.loading(isLoading: viewModel.isLoading))
    }
    func display(viewModel: FeedViewModel) {
        msg.insert(.display(feed: viewModel.feeds))
    }
}

extension FeedErrorViewModel: Equatable {}
