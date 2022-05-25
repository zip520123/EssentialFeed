//

import Foundation

public enum FeedEndpoint {
    public static func get(baseURL: URL, after image: FeedImage? = nil) -> URL {
        let url = baseURL.appendingPathComponent("v1/feed")

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "10"),
            image.map { URLQueryItem(name: "after_id", value: $0.id.uuidString) }
        ].compactMap { $0 }
        return components!.url!
    }
}

