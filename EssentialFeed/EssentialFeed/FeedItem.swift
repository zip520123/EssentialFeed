//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by zip520123 on 12/08/2021.
//

import Foundation

public struct FeedImage: Hashable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = url
    }
    
}

