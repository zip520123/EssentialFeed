import XCTest
import EssentialFeed

class SharedLocalizationStringTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExist(bundle, table)
    }

    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }

}
