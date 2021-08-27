//
//  URLHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 27/08/2021.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void ) {
        let task = session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}
class URLHTTPClientTests: XCTestCase {
    
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        
        let url = URL(string: "http://a-url.com")!
        let error = NSError(domain: "any error", code: 1)
        
        let sut = URLSessionHTTPClient()
        
        URLProtocolStub.stub(url, data: nil, response: nil, error: error)
        let expect = expectation(description: "wait for completion")
        sut.get(from: url) {result in
            switch result {
            case let .failure(recievedError as NSError):
                XCTAssertEqual(recievedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 1)
        
        URLProtocolStub.stopInterceptingRequests()
        
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stub = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(_ url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stub[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub.removeAll()
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {return false}
            return stub[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stub[url] else {return}
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
