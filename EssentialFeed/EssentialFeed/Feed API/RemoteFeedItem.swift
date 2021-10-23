//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by zip520123 on 14/09/2021.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
