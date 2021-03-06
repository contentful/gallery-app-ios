//
//  Image.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreData
import Contentful
import ContentfulPersistence

class Image: NSManagedObject, EntryPersistable {

    static let contentTypeId = "image"
    
    @NSManaged var localeCode: String?
    @NSManaged var id: String
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
    @NSManaged var title: String
    @NSManaged var imageCaption: String?
    @NSManaged var imageCredits: String?
    @NSManaged var photo: Asset?
    
    @NSManaged var createdEntriesInverse: NSSet
    @NSManaged var imagesInverse: NSSet

    static func fieldMapping() -> [FieldName: String] {
        return [
            "title": "title",
            "photo": "photo",
            "imageCaption": "imageCaption",
            "imageCredits": "imageCredits"
        ]
    }
}
