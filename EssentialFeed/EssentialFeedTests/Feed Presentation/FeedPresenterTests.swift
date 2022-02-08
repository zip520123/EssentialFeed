import XCTest

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedErrorViewModel {
    let errorMessage: String?
}

final class FeedPresenter {
    let feedErrorView: FeedErrorView
    init(feedErrorView: FeedErrorView) {
        self.feedErrorView = feedErrorView
    }
    func didStartLoadingFeed() {
        feedErrorView.display(FeedErrorViewModel(errorMessage: nil))
    }
}
class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.msg.isEmpty)
    }

    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.msg, [FeedErrorViewModel(errorMessage: nil)])

    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)

    }
}

class ViewSpy: FeedErrorView {
    private(set) var msg = [FeedErrorViewModel]()
    func display(_ viewModel: FeedErrorViewModel) {
        msg.append(viewModel)
    }
}

extension FeedErrorViewModel: Equatable {}
