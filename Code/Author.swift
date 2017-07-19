//
//  Author.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreData
import Contentful
import ContentfulPersistence

class Author: NSManagedObject, EntryPersistable {

    static let contentTypeId = "38nK0gXXIccQ2IEosyAg6C"

    @NSManaged var id: String
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?

    @NSManaged var biography: String?
    @NSManaged var name: String
    @NSManaged var twitterHandle: String?
    @NSManaged var authorInverse: NSSet
    @NSManaged var createdEntries: NSOrderedSet
    @NSManaged var profilePhoto: Asset?

    static func mapping() -> [FieldName: String] {
        return [
            "name": "name",
            "biography": "biography",
            "twitterHandle": "twitterHandle",
            "createdEntries": "createdEntries",
            "profilePhoto": "profilePhoto"
        ]
    }
}
