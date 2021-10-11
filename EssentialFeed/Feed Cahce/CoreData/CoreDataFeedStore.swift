//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by zip520123 on 10/10/2021.
//
import CoreData

public final class CoreDataFeedStore: FeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    struct ModelNotFound: Error {
        let modelName: String
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
        }
        
        container = try NSPersistentContainer.load(
            name: CoreDataFeedStore.modelName,
            model: model,
            url: storeURL
        )
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { (context) in
            do {
                if let cache = try Cache.find(in: context) {
                    completion(.success(.found(cache.localFeeds, cache.timestamp)))
                } else {
                    completion(.success(.empty))
                }
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let cache = try Cache.newUniqueInstance(in: context)
                
                cache.timestamp = timestamp
                cache.feeds = Feed.feeds(from: feed, context)
                
                try context.save()
                
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { (context) in
            do {
                if let cache = try Cache.find(in: context) {
                    context.delete(cache)
                    try context.save()
                }
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }
}


extension NSPersistentContainer {
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    convenience init?(name: String, in bundle: Bundle) {
        guard let momd = bundle.url(forResource: name, withExtension: "momd") else {
            return nil
        }
        self.init(contentsOf: momd)
    }
}
