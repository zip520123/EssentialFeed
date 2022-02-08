import XCTest

final class FeedPresenter {
    init(view: Any) {

    }
}
class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)

        XCTAssertTrue(view.message.isEmpyt)
    }
}

class ViewSpy {
    let msg = [Any]()
}
