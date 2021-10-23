//
//  Cache+CoreDataClass.swift
//  FeedStoreChallenge
//
//  Created by zip520123 on 02/10/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import CoreData

@objc(Cache)
final class Cache: NSManagedObject {}
extension Cache {
	@NSManaged var timestamp: Date
	@NSManaged var feeds: NSOrderedSet
}

extension Cache {
	static func find(in context: NSManagedObjectContext) throws -> Cache? {
		let request = NSFetchRequest<Cache>(entityName: entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}

	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> Cache {
		try find(in: context).map(context.delete)
		return Cache(context: context)
	}

	var localFeeds: [LocalFeedImage] {
		return feeds.compactMap { ($0 as? Feed)?.local }
	}
}
