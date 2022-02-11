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
}
class FeedPresenterTests: XCTestCase {
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

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view, loadingView: view, feedView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)

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
