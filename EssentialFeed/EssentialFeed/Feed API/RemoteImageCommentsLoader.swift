

import Foundation

public final class RemoteImageCommentsLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = Swift.Result<[ImageComment], Swift.Error>

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
            return .success(items)
        } catch {
            return .failure(error)
        }
    }

}

