import XCTest
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

final class FeedPresenter {
    let feedErrorView: FeedErrorView
    let loadingView: FeedLoadingView
    init(feedErrorView: FeedErrorView, loadingView: FeedLoadingView) {
        self.feedErrorView = feedErrorView
        self.loadingView = loadingView
    }
    func didStartLoadingFeed() {
        feedErrorView.display(FeedErrorViewModel(errorMessage: nil))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
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

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view, loadingView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)

    }
}

class ViewSpy: FeedErrorView, FeedLoadingView {


    enum Message: Equatable {
        case error(msg: String?)
        case loading(isLoading: Bool)
    }
    private(set) var msg = [Message]()
    func display(_ viewModel: FeedErrorViewModel) {
        msg.append(.error(msg: viewModel.errorMessage))
    }
    func display(viewModel: FeedLoadingViewModel) {
        msg.append(.loading(isLoading: viewModel.isLoading))
    }
}

extension FeedErrorViewModel: Equatable {}
