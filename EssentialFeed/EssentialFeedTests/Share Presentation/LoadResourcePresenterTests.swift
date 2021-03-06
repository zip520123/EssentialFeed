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

    func test_finishedLoadingWithMapperError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
            throw anyNSError()
        })

        sut.didFinishLoading(with: "resource")

        XCTAssertEqual(view.msg, [
            .error(msg: localized("GENERIC_CONNECTION_ERROR") ),
            .loading(isLoading: false)
        ])
    }

    func test_finishedLoading_displayErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        let error = anyNSError()
        sut.didFinishLoading(with: error)

        XCTAssertEqual(view.msg, [
            .error(msg: localized("GENERIC_CONNECTION_ERROR") ),
            .loading(isLoading: false)
        ])
    }

    private typealias SUT = LoadResourcePresenter<String, ViewSpy>

    private func makeSUT(
        mapper: @escaping (String) throws -> String = { _ in "any" },
        file: StaticString = #file,
        line: UInt = #line) -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(resourceErrorView: view, loadingView: view, resourceView: view, mapper: mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)

    }

    private class ViewSpy: ResourceErrorView, ResourceLoadingView, ResourceView {
        typealias ResourceViewModel = String
        enum Message: Hashable {
            case error(msg: String?)
            case loading(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        private(set) var msg = Set<Message>()
        func display(_ viewModel: ResourceErrorViewModel) {
            msg.insert(.error(msg: viewModel.errorMessage))
        }
        func display(viewModel: ResourceLoadingViewModel) {
            msg.insert(.loading(isLoading: viewModel.isLoading))
        }
        func display(_ viewModel: String) {
            msg.insert(.display(resourceViewModel: viewModel))
        }
    }

    func localized(_ key: String, _ file: StaticString = #file, _ line: UInt = #line) -> String {
        let table = "Shared"
        let bundle = Bundle(for: SUT.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized String for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

}
