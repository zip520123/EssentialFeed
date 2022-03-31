//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 03/12/2021.
//
import EssentialFeed

public struct FeedImageCellViewModel<Image> {
    
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    

    public var hasLocation: Bool {
        return location != nil
    }
}
