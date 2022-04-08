//
//  URLHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 27/08/2021.
//

import XCTest
import EssentialFeed


class URLHTTPClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub() 
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        
        let url = anyURL()
        let exp = expectation(description: "wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        _ = makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
        
        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
        XCTAssertEqual((receivedError as NSError?)?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receviedValues = resultValueFor((data: data, response: response, error: nil))
        
        XCTAssertEqual(receviedValues?.data, data)
        XCTAssertEqual(receviedValues?.response.url, response?.url)
        XCTAssertEqual(receviedValues?.response.statusCode, response?.statusCode)
    }
    
    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        
        let receviedValues = resultValueFor((data: nil, response: response, error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(receviedValues?.data, emptyData)
        XCTAssertEqual(receviedValues?.response.url, response?.url)
        XCTAssertEqual(receviedValues?.response.statusCode, response?.statusCode)
        
    }

    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor(handler: { $0.cancel() }) as NSError?
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)

    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)

        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultValueFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, file: file, line: line)
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, handler: (HTTPClientTask)->() = {_ in}, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(values, handler: handler, file: file, line: line)
        
        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }

    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, handler: (HTTPClientTask)->() = {_ in}, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        let expect = expectation(description: "wait for completion")
        let sut = makeSUT(file: file, line: line)
        var receivedResult: HTTPClient.Result!

        handler(sut.get(from: anyURL()) { result in
            receivedResult = result
            expect.fulfill()
        })
        
        wait(for: [expect], timeout: 1)
        return receivedResult
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse? {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
    }
    
}
