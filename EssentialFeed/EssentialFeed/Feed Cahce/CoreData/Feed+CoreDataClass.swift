//
//  Feed+CoreDataClass.swift
//  FeedStoreChallenge
//
//  Created by zip520123 on 02/10/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import CoreData

@objc(Feed)
final class Feed: NSManagedObject {
    @NSManaged var descriptionString: String?
    @NSManaged var id: UUID
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: Cache
}
extension Feed {
	var local: LocalFeedImage {
		return LocalFeedImage(id: id, description: descriptionString, location: location, url: url)
	}

	static func feeds(from images: [LocalFeedImage], _ context: NSManagedObjectContext) -> NSOrderedSet {

		let array = NSOrderedSet(array: images.map { [context] image in
			let coreDataFeed = Feed(context: context)

			coreDataFeed.id = image.id
			coreDataFeed.location = image.location
			coreDataFeed.url = image.url
			coreDataFeed.descriptionString = image.description
            coreDataFeed.data = context.userInfo[image.url] as? Data

			return coreDataFeed
		})

        context.userInfo.removeAllObjects()
        return array
	}

    static func first(with url: URL, in context: NSManagedObjectContext) throws -> Feed? {
        let request = NSFetchRequest<Feed>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Feed.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func data(for url: URL, in context: NSManagedObjectContext) throws -> Data? {
        if let data = context.userInfo[url] as? Data {
            return data
        }
        return try first(with: url, in: context)?.data
    }

    override func prepareForDeletion() {
        super.prepareForDeletion()
        managedObjectContext?.userInfo[url] = data
    }
}
