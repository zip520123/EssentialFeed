//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialAppUIKit
import Combine

class CommetsUIIntegrationTests: FeedUIIntegrationTests {

    func test_CommentsView_hasTitle() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, ImageCommentsPresenter.title)
    }

    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests beview view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a load")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected a third loading request once user initiates another load")
    }

    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed successfully")


        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator when user initiate a load")

        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completes with error")

    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comments0 = makeComment(message: "a description", username: "a username")
        let comments1 = makeComment(message: "another description", username: "another username")

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.numberOfRenderedComments(), 0)

        loader.completeCommentsLoading(with: [comments0], at: 0)

        XCTAssertEqual(sut.numberOfRenderedComments(), 1)

        assertThat(sut, shouldRender: [comments0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comments0, comments1], at: 1)
        XCTAssertEqual(sut.numberOfRenderedComments(), 2)

        assertThat(sut, shouldRender: [comments0, comments1])

    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment = makeComment()

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, shouldRender: [comment])

        sut.simulateUserInitiatedReload()

        loader.completeCommentsLoading(with: [], at: 1)

        assertThat(sut, shouldRender: [])

    }

    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, shouldRender: [comment])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)

        assertThat(sut, shouldRender: [comment])
    }

    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainTread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    override func test_loadFail_displayErrorMsg() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        loader.completeCommentsLoadingWithError()
        XCTAssertTrue(sut.errorViewIsVisible())
    }

    override func test_tapErrorMsg_hideErrorView() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoadingWithError()
        sut.simulateTapOnErrorMessage()
        XCTAssertFalse(sut.errorViewIsVisible())
    }

    override func test_simulatePullRequest_hideErrorView() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoadingWithError()
        sut.simulateUserInitiatedReload()
        XCTAssertFalse(sut.errorViewIsVisible())
    }

    //MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)

        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    fileprivate func anyImageData() -> Data {
        return UIImage.make(with: .red).pngData()!
    }

    private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
        ImageComment(id: UUID(), message: message, createAt: Date(), username: username)
    }

    private func assertThat(_ sut: ListViewController, shouldRender comments: [ImageComment],  file: StaticString = #file, line: UInt = #line) {

        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)

        let viewModel = ImageCommentsPresenter.map(comments)

        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username)
            XCTAssertEqual(sut.commentDate(at: index), comment.date)

        }
    }

    class LoaderSpy {

        var loadCommentsCallCount: Int { requests.count }
        private(set) var requests = [PassthroughSubject<[ImageComment], Swift.Error>]()

        func loadPublisher() -> AnyPublisher<[ImageComment], Swift.Error> {

            let publisher = PassthroughSubject<[ImageComment], Swift.Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int) {
            requests[index].send(comments)
        }

        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "Any Error", code: 0, userInfo: nil)
            requests[index].send(completion: .failure(error))
        }


    }
}
