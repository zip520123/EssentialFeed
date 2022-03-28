
public protocol ImageDataCacheLoader {
    func save(_ data: Data, for url: URL, completion: @escaping (LocalFeedImageDataLoader.SaveResult)->Void)
}
