//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by zip520123 on 20/09/2021.
//

protocol FeedStoreSpecs {
    func test_retrieve_deliverEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_overridePreviouslyInsertedCachedValues()
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliverNoErrorOnEmptyCache()
    func test_delete_emptiesPreivouslyInsertedCache()
    func test_delete_deliverNoErrorOnNonEmptyCache()
    
    func test_storeSideEffect_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectOnDeletionError()
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
