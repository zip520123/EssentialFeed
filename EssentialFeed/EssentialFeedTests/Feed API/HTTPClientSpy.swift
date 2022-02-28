
import EssentialFeed
class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        let callback: ()->()
        func cancel() {
            callback()
        }
    }

    private var msgs = [(URL, (HTTPClient.Result) -> Void)]()
    var requests: [URL] {
        msgs.map{$0.0}
    }

    private(set) var cancelledURLs = [URL]()

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        msgs.append((url,completion))
        return Task { [weak self] in self?.cancelledURLs.append(url) }
    }

    func complete(with error: Error, at index: Int = 0){
        msgs[index].1(.failure(error))
    }

    func complete(status code: Int, data: Data, at index: Int = 0) {
        let res = HTTPURLResponse(url: msgs[index].0, statusCode: code, httpVersion: nil, headerFields: nil)!
        msgs[index].1(.success((data, res)))
    }
}
