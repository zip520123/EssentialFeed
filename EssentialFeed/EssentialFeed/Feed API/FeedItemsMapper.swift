//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by zip520123 on 24/08/2021.
//

import Foundation

public struct FeedItemMapper {
    private struct Root: Decodable {
        private struct RemoteFeedItem: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }

        private let items: [RemoteFeedItem]

        var images: [FeedImage] {
            items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }
    enum Error: Swift.Error {
        case invalidData
    }
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data)
        else { throw Error.invalidData }
        return root.images
    }
}

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}


public struct FeedImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }

        return data
    }
}
