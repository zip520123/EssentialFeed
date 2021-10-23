//
//  ShareTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 16/09/2021.
//

import Foundation
func anyURL() -> URL {
    URL(string: "http://a-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}
