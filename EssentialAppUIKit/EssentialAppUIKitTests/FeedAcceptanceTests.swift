//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialAppUIKit

class FeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {

        let feed = launch(httpClient: .online(response), store: .empty)

        XCTAssertEqual(feed.numberOfRenderedFeedImageView(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData2())
        XCTAssertTrue(feed.canLoadMoreFeed())

        feed.simulateLoadMoreFeedAction()
        XCTAssertEqual(feed.numberOfRenderedFeedImageView(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData2())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData3())
        XCTAssertTrue(feed.canLoadMoreFeed())

        feed.simulateLoadMoreFeedAction()
        XCTAssertEqual(feed.numberOfRenderedFeedImageView(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData2())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData3())
        XCTAssertFalse(feed.canLoadMoreFeed())
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectiviry() {

        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisiable(at: 0)
        onlineFeed.simulateFeedImageViewVisiable(at: 1)
        onlineFeed.simulateLoadMoreFeedAction()
        onlineFeed.simulateFeedImageViewVisiable(at: 2)

        let offlineFeed = launch(httpClient: .offline, store: sharedStore)

        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageView(), 3)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData1())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData2())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 2), makeImageData3())
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        XCTAssertEqual(feed.numberOfRenderedFeedImageView(), 0)
    }

    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }

    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }

    func test_onFeedImageSelection_displayComments() {

        let comments = showCommentsForFirstImage()

        XCTAssertEqual(comments.numberOfRenderedComments(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
    }

    // MARK: - Helpers
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty
    ) -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store, scheduler: AnyScheduler.immediateOnMainQueue)
        sut.window = UIWindow()
        sut.configureWindow()

        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! ListViewController
    }

    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store, scheduler: AnyScheduler.immediateOnMainQueue)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }

    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }

        private let stub: (URL) -> HTTPClient.Result

        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }

        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }

        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url)) }
        }
    }

    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        private(set) var feedCache: CacheFeed?
        private var feedImageDataCache: [URL: Data] = [:]

        private init(feedCache: CacheFeed? = nil) {
            self.feedCache = feedCache
        }

        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }

        func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
            feedCache = CacheFeed(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }

        func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
            completion(.success(feedCache))
        }

        func insert(_ data: Data, for url: URL) throws {
            feedImageDataCache[url] = data
        }

        func retrieve(dataForURL url: URL) throws -> Data? {
            feedImageDataCache[url]
        }

        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }

        static var withExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CacheFeed(feed: [], timestamp: Date.distantPast))
        }

        static var withNonExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CacheFeed(feed: [], timestamp: Date()))
        }

    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.path {
        case "/image-1":
            return makeImageData1()
        case "/image-2":
            return makeImageData2()
        case "/image-3":
            return makeImageData3()

        case "/essential-feed/v1/feed" where url.query?.contains("after_id") == false:
            return makeFirstFeedPageData()

        case "/essential-feed/v1/feed" where url.query?.contains("after_id=A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A") == true:
            return makeSecondFeedPageData()

        case "/essential-feed/v1/feed" where url.query?.contains("after_id=F71E9FCD-4CB1-4C83-9D40-E6B992BF2143") == true:
            return makeLastEmptyFeedPageData()

        case "/essential-feed/v1/image/2AB2AE66-A4B7-4A16-B374-51BBAC8DB086/comments":
            return makeCommentsData()

        default:
            XCTFail("Unknow path: \(url.path)")
            return Data()
        }
    }

    private func makeImageData3() -> Data {
        return UIImage.make(with: .red).pngData()!
    }

    private func makeImageData1() -> Data {
        return UIImage.make(with: .green).pngData()!
    }

    private func makeImageData2() -> Data {
        return UIImage.make(with: .blue).pngData()!
    }

    private func makeFirstFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086", "image": "http://feed.com/image-1"],
            ["id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A", "image": "http://feed.com/image-2"]
        ]])
    }

    private func makeSecondFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "F71E9FCD-4CB1-4C83-9D40-E6B992BF2143", "image": "http://feed.com/image-3"]
        ]])
    }

    private func makeLastEmptyFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": []])
    }

    private func showCommentsForFirstImage() -> ListViewController {
        let feedVC = launch(httpClient: .online(response), store: .empty)
        feedVC.simulateTapOnFeedImage(at: 0)
        RunLoop.current.run(until: Date())

        let nav = feedVC.navigationController
        return nav?.topViewController as! ListViewController
    }

    private func makeCommentsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            [
                "id": UUID().uuidString,
                "message": makeCommentMessage(),
                "created_at": "2020-05-20T11:24:59+0000",
                "author": [
                    "username": "a username"
                ]
            ],
        ]])
    }

    private func makeCommentMessage() -> String {
        "a message"
    }
}
