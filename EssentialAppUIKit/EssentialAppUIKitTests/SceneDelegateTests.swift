import XCTest
import EssentialFeediOS
@testable import EssentialAppUIKit

class SceneDelegateTests: XCTestCase {

    func test_configureWindow_setsWindowAsKeyAndVisiable() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        sut.configureWindow()

        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1)
    }

    class UIWindowSpy: UIWindow {
        private(set) var makeKeyAndVisibleCallCount: Int = 0
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCallCount += 1
        }
    }

    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation)
        XCTAssertTrue(topController is ListViewController)

    }

}
