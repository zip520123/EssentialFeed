import XCTest

class RemoteImageDataLoaderTask: FeedImageDataLoaderTask {
    func cancel() {

    }
}
class RemoteImageDataLoader: FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return RemoteImageDataLoaderTask()
    }
}

class LoadImageFromRemoteUseCaseTests: XCTestCase {
//    func test_init_loadData() {
//        let sut = RemoteImageDataLoader()
//        var spy = [FeedImageDataLoader.Result]()
//        sut.loadImageData(from: anyURL()) { result in
//            spy.append(result)
//        }
//        XCTAssertEqual(spy, [])
//    }


}
