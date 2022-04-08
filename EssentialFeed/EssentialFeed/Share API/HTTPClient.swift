//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by zip520123 on 24/08/2021.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to approripate threads, if needed
    func get(from url: URL, completion: @escaping (Result)->Void) -> HTTPClientTask
    
}
