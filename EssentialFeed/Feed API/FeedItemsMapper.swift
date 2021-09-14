//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by zip520123 on 24/08/2021.
//

import Foundation


struct FeedItemMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static let ok_200: Int = 200
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == ok_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else { throw RemoteFeedLoader.Error.invalidData }
        return root.items
    }
}
