
import Foundation
import XCTest
import EssentialFeed
extension FeedUIIntegrationTests {
    func localized(_ key: String, _ file: StaticString = #file, _ line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized String for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

