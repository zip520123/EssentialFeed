//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by zip520123 on 12/08/2021.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
