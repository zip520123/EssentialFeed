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

    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.numberOfRenderedFeedImageView(), 0)

        loader.completeCommentsLoading(with: [image0], at: 0)

        XCTAssertEqual(sut.numberOfRenderedFeedImageView(), 1)

        assertThat(sut, with: image0, at: 0)

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [image0, image1, image2, image3], at: 1)
        XCTAssertEqual(sut.numberOfRenderedFeedImageView(), 4)

        assertThat(sut, with: image0, at: 0)
        assertThat(sut, with: image1, at: 1)
        assertThat(sut, with: image2, at: 2)
        assertThat(sut, with: image3, at: 3)
    }

    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeCommentsLoading(with: [image0, image1], at: 0)
        assertThat(sut, shouldRender: [image0, image1])

        sut.simulateUserInitiatedReload()

        loader.completeCommentsLoading(with: [], at: 1)

        assertThat(sut, shouldRender: [])

    }

    override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        loader.completeCommentsLoading(with: [image0], at: 0)
        assertThat(sut, shouldRender: [image0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)

        assertThat(sut, shouldRender: [image0])
    }

    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainTread() {
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

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    private func assertThat(_ sut: ListViewController, shouldRender images: [FeedImage],  file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())

        XCTAssertEqual(sut.numberOfRenderedFeedImageView(), images.count, "image count != numberOfRenderedFeedImageView")
        images.enumerated().forEach { assertThat(sut, with: $1, at: $0, file: file, line: line) }
    }

    private func assertThat(_ sut: ListViewController, with image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index) as? FeedImageCell
        XCTAssertNotNil(view, file: file, line: line)
        let shouldShowLocation = image.location != nil
        XCTAssertEqual(view?.isShowingLocation, shouldShowLocation, "Expected show location, got \(shouldShowLocation) instead at \(index)", file: file, line: line)
        XCTAssertEqual(view?.locationText, image.location, "Expected location text \(String(describing: image.location)), got \(String(describing: view?.locationText)) instead at index: \(index)" , file: file, line: line)
        XCTAssertEqual(view?.descriptionText, image.description, "Expected description text \(String(describing: image.description)), got \(String(describing: view?.descriptionText)) instead at index: \(index)" ,file: file, line: line)
    }

    class LoaderSpy {

        var loadCommentsCallCount: Int { requests.count }
        private(set) var requests = [PassthroughSubject<[FeedImage], Swift.Error>]()

        func loadPublisher() -> AnyPublisher<[FeedImage], Swift.Error> {

            let publisher = PassthroughSubject<[FeedImage], Swift.Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeCommentsLoading(with feed: [FeedImage] = [], at index: Int) {
            requests[index].send(feed)
        }

        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "Any Error", code: 0, userInfo: nil)
            requests[index].send(completion: .failure(error))
        }


    }
}
