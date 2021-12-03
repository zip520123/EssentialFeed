//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 03/12/2021.
//
import EssentialFeed

final class FeedImageCellViewModel<Image> {
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    var location: String? {
        model.location
    }
    
    var description: String? {
        model.description
    }
    
    init(task: FeedImageDataLoaderTask? = nil, model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image? ) {
        self.task = task
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    typealias Observer<T> = (T)->()
    
    var didLoadImage: Observer<Image?>?
    var shouldHideButton: Observer<Bool>?
    var shimmering: Observer<Bool>?
    
    func loadImage() {
        shimmering?(true)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            guard let self = self else {return}
            let data = (try? result.get())
            let image = data.map(self.imageTransformer) ?? nil
            self.didLoadImage?(image)
            self.shouldHideButton?(image != nil)
            self.shimmering?(false)
        }
    }
    
    func cancel() {
        task?.cancel()
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.imageURL, completion: { _ in })
    }
    
}
