//

import Foundation

struct ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data)
        else { throw RemoteImageCommentsLoader.Error.invalidData }
        return root.items
    }

    private static func isOK(_ res: HTTPURLResponse) -> Bool {
        switch res.statusCode {
        case 200...299:
            return true
        default:
            return false
        }
    }
}

