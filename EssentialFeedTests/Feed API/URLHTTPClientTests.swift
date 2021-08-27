//
//  URLHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 27/08/2021.
//

import XCTest
class URLSessionHTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        let task = session.dataTask(with: url) { (_, _, _) in
            
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
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
        
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        
        private var stub = [URL: URLSessionDataTask]()
        func stub(_ url: URL, task: URLSessionDataTask) {
            stub[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            return stub[url] ?? FakeURLSessionDataTask()
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
