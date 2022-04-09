import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {

    func test_map_createsViewModel() {
        let image = uniqueImage()
        let viewModel = FeedImagePresenter<ViewSpy, AnyImage>.map(image)
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }

    func test_init_doesNotSendMsg() {
        let (view, _) = makeSUT()
        XCTAssertTrue(view.displayEvent.isEmpty)
    }

    func test_didStartLoading() throws {
        let (view, sut) = makeSUT()
        let image = uniqueImage()

        sut.didStartLoadingImageData(for: image)
        XCTAssertEqual(view.displayEvent.count, 1)
        let msg = try XCTUnwrap(view.displayEvent.first)

        XCTAssertEqual(msg.description, image.description)
        XCTAssertEqual(msg.location, image.location)
        XCTAssertNil(msg.image)
        XCTAssertEqual(msg.isLoading, true)
        XCTAssertEqual(msg.shouldRetry, false)
    }

    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() throws {
        let failTf: ((Data)->AnyImage?) = {_ in nil}
        let (view, sut) = makeSUT(tf: failTf)
        let image = uniqueImage()

        sut.didFinishLoadingImageData(with: Data(), for: image)
        XCTAssertEqual(view.displayEvent.count, 1)
        let msg = try XCTUnwrap(view.displayEvent.first)
        XCTAssertEqual(msg.description, image.description)
        XCTAssertEqual(msg.location, image.location)
        XCTAssertNil(msg.image)
        XCTAssertEqual(msg.isLoading, false)
        XCTAssertEqual(msg.shouldRetry, true)
    }

    func test_finishLoadingImageDataWithError_showRetry() throws {
        let (view, sut) = makeSUT()
        let image = uniqueImage()

        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        XCTAssertEqual(view.displayEvent.count, 1)
        let msg = try XCTUnwrap(view.displayEvent.first)
        XCTAssertEqual(msg.description, image.description)
        XCTAssertEqual(msg.location, image.location)
        XCTAssertNil(msg.image)
        XCTAssertEqual(msg.isLoading, false)
        XCTAssertEqual(msg.shouldRetry, true)
    }

    func test_didFinishLoadingImageData_displayImageOnSuccessTransformation() throws {
        let image = uniqueImage()
        let transformedData = AnyImage()
        let tf: ((Data)->AnyImage?) = { _ in transformedData }
        let (view, sut) = makeSUT(tf: tf)

        sut.didFinishLoadingImageData(with: Data(), for: image)

        XCTAssertEqual(view.displayEvent.count, 1)
        let msg = try XCTUnwrap(view.displayEvent.first)
        XCTAssertEqual(msg.description, image.description)
        XCTAssertEqual(msg.location, image.location)
        XCTAssertEqual(msg.image, transformedData)
        XCTAssertEqual(msg.isLoading, false)
        XCTAssertEqual(msg.shouldRetry, false)
    }


    private class ViewSpy: FeedImageView {
        private(set) var displayEvent = [FeedImageCellViewModel<AnyImage>]()
        func display(_ model: FeedImageCellViewModel<AnyImage>) {
            displayEvent.append(model)
        }
    }

    private func makeSUT(tf: @escaping (Data)-> AnyImage? = {_ in nil}, file: StaticString = #file, line: UInt = #line) -> (ViewSpy, FeedImagePresenter<ViewSpy, AnyImage>) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: tf)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (view, sut)
    }

    private struct AnyImage: Equatable {}

}
