

import Foundation

public final class RemoteImageCommentsLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = FeedLoader.Result

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        _ = client.get(from: url) {[weak self] result in
            guard self != nil else {return}
            switch result {
            case let .success((data, response)):
                completion(RemoteImageCommentsLoader.map(data, response))

            case .failure:
                completion(.failure(RemoteImageCommentsLoader.Error.connectivity))
            }
        }
    }

    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsMapper.map(data, response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }

}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}


