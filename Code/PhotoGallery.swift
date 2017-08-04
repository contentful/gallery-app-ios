//
//  PhotoGallery.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreData
import Contentful
import ContentfulPersistence

class Photo_Gallery: NSManagedObject, EntryPersistable {

    static let contentTypeId = "7leLzv8hW06amGmke86y8G"

    @NSManaged var id: String
    @NSManaged var localeCode: String
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?

    @NSManaged var title: String?
    @NSManaged var date: Date?
    @NSManaged var galleryDescription: String?
    @NSManaged var slug: String?
    @NSManaged var author: Author?
    @NSManaged var coverImage: Asset?
    @NSManaged var images: NSOrderedSet

    static func fieldMapping() -> [FieldName: String] {
        return [
            "title": "title",
            "date": "date",
            "description": "galleryDescription",
            "coverImage": "coverImage",
            "slug": "slug",
            "author": "author",
            "images": "images"
        ]
    }
}
