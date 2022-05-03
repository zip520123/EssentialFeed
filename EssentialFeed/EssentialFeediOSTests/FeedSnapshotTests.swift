
import XCTest
@testable import EssentialFeediOS
import EssentialFeed

class FeedSnapshotTests: XCTestCase {

    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }

    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()

        sut.display(feedWithLoadMoreIndicator())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
    }

    // MARK: - Helpers
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(with: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(with: .green)
            )
        ]
    }

    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(
                description: nil,
                location: "Cannon Street, London",
                image: nil
            ),
            ImageStub(
                description: nil,
                location: "Brighton Seafront",
                image: nil
            )
        ]
    }

    private func feedWithLoadMoreIndicator() -> [CellController] {
        let stub = feedWithContent().last!
        let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
        let loadMore = LoadMoreCellController()
        loadMore.display(viewModel: ResourceLoadingViewModel(isLoading: true))
        return  [CellController(id: UUID(), cellController), CellController(id: UUID(), loadMore)]
    }

}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map { stub in
            let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
            stub.controller = cellController
            return CellController(id: cellController, cellController)
        }

        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageCellViewModel
    weak var controller: FeedImageCellController?
    let image: UIImage?
    init(description: String?, location: String?, image: UIImage?) {
        self.image = image
        viewModel = FeedImageCellViewModel(
            description: description,
            location: location)
    }

    func didRequestImage() {
        controller?.display(viewModel: ResourceLoadingViewModel(isLoading: false))

        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(errorMessage: .none))
        } else {
            controller?.display(ResourceErrorViewModel(errorMessage: "any"))
        }
    }

    func didCancelImageRequest() {}
}

