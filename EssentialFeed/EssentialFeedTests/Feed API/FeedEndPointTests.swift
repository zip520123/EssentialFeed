//

import XCTest
import EssentialFeed

class FeedEndPointTests: XCTestCase {

    func test_feed_endPointURL() {
        let baseURL = URL(string: "https://base-url.com")!

        let received = FeedEndpoint.get(baseURL: baseURL)

        XCTAssertEqual(received.scheme, "https")
        XCTAssertEqual(received.host, "base-url.com")
        XCTAssertEqual(received.path, "/v1/feed")
        XCTAssertEqual(received.query, "limit=10", "query")
    }

}
