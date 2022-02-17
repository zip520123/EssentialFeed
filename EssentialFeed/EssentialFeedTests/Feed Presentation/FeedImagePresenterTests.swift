import XCTest
import EssentialFeed

struct FeedImageCellViewModel<Image> {

    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool


    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageCellViewModel<Image>)
}

class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(_ view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageCellViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }

    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageCellViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil))
    }

    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageCellViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}

class FeedImagePresenterTests: XCTestCase {
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
        let (view, sut) = makeSUT()
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

    private func makeSUT(tf: @escaping (Data)-> AnyImage? = {_ in nil}) -> (ViewSpy, FeedImagePresenter<ViewSpy, AnyImage>) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view, imageTransformer: tf)
        return (view, sut)
    }

    private struct AnyImage: Equatable {}

}
