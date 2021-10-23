//
//  NSManagedObjectContext+Stub.swift
//  Tests
//
//  Created by Caio Zullo on 01/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
	static func alwaysFailingFetchStub() -> Stub {
		Stub(
			#selector(NSManagedObjectContext.fetch(_:)),
			#selector(Stub.fetch(_:))
		)
	}

	static func alwaysFailingSaveStub() -> Stub {
		Stub(
			#selector(NSManagedObjectContext.save),
			#selector(Stub.save)
		)
	}

	class Stub: NSObject {
		private let source: Selector
		private let destination: Selector

		init(_ source: Selector, _ destination: Selector) {
			self.source = source
			self.destination = destination
		}

		@objc func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
			throw anyNSError()
		}

		@objc func save() throws {
			throw anyNSError()
		}

		func startIntercepting() {
			method_exchangeImplementations(
				class_getInstanceMethod(NSManagedObjectContext.self, source)!,
				class_getInstanceMethod(Stub.self, destination)!
			)
		}

		deinit {
			method_exchangeImplementations(
				class_getInstanceMethod(Stub.self, destination)!,
				class_getInstanceMethod(NSManagedObjectContext.self, source)!
			)
		}
	}
}
