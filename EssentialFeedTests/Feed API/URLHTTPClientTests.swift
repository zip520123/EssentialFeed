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
    init(session: URLSession) {
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
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let task = URLSessionDataTaskSpy()
        session.stub(url, task: task)
        sut.get(from: url) {_ in}
        
        XCTAssertEqual(task.resumeCallCount, 1)
        
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://a-url.com")!
        let error = NSError(domain: "any error", code: 1)
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let task = URLSessionDataTaskSpy()
        session.stub(url, task: task, error: error)
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
        
        XCTAssertEqual(task.resumeCallCount, 1)
        wait(for: [expect], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        
        private var stub = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(_ url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stub[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stub[url] else {
                fatalError("couldn't find stub for \(url)")
            }
            completionHandler(nil, nil,stub.error)
            return stub.task
            
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }
}
