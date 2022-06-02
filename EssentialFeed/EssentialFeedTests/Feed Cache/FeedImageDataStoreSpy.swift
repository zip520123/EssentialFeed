import EssentialFeed
class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Msg: Equatable {
        case retreive(dataFor: URL)
        case insert(data: Data, for: URL)
    }

    private(set) var receivedMessages = [Msg]()
    private var retrievalCompletions = [(FeedImageDataLoader.Result) -> Void]()
    private var insertionResult: Result<Void, Error>?

    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        receivedMessages.append(.retreive(dataFor: url))
        retrievalCompletions.append(completion)
    }

    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }

    func complete(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func complete(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
}
