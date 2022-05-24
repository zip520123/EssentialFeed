//

import Foundation

public enum FeedEndpoint {
    public static func get(baseURL: URL) -> URL {
        let url = baseURL.appendingPathComponent("v1/feed")

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "10"),
        ]
        return components!.url!
    }
}

