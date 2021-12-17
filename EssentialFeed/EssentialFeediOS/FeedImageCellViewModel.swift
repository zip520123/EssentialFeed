//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 03/12/2021.
//
import EssentialFeed

struct FeedImageCellViewModel<Image> {
    
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    

    var hasLocation: Bool {
        return location != nil
    }
}
