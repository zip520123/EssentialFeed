//
//  MainQueueDistpatchDecorator.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 01/01/2022.
//

import EssentialFeed
import Foundation

final class MainQueueDispatchDecorator<T> {
    
    private let decoratee: T
    internal init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping ()-> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { completion() }
            return
        }
        completion()
    }
}


extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] (result) in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
