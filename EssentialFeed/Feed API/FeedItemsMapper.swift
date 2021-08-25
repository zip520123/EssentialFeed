//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by zip520123 on 24/08/2021.
//

import Foundation
struct FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
        var feed: [FeedItem] {
            items.map {$0.item}
        }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    private static let ok_200: Int = 200
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == ok_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else { return .failure(RemoteFeedLoader.Error.invalidData) }
        return (.success(root.feed))
    }
}
