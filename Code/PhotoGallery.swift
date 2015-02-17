//
//  PhotoGallery.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreData

class PhotoGallery: NSManagedObject, CDAPersistedEntry {

    @NSManaged var date: NSDate
    @NSManaged var galleryDescription: String
    @NSManaged var identifier: String
    @NSManaged var location: AnyObject
    @NSManaged var slug: String
    @NSManaged var title: String
    @NSManaged var author: Author?
    @NSManaged var coverImage: Asset
    @NSManaged var images: NSOrderedSet

}
