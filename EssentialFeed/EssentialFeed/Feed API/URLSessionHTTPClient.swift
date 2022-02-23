//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by zip520123 on 31/08/2021.
//

import Foundation
public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}

    private struct URLSessionHTTPTask: HTTPClientTask {
        let uRLSessionDataTask: URLSessionDataTask
        func cancel() {
            uRLSessionDataTask.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void ) -> HTTPClientTask {
        let task = session.dataTask(with: url) { (data, response, error) in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
            
        }
        task.resume()

        return URLSessionHTTPTask(uRLSessionDataTask: task)
    }
    
}
