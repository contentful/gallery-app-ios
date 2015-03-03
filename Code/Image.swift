//
//  Image.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreData

class Image: NSManagedObject, CDAPersistedEntry {

    @NSManaged var identifier: String
    @NSManaged var imageCaption: String?
    @NSManaged var imageCredits: String?
    @NSManaged var title: String
    @NSManaged var createdEntriesInverse: NSSet
    @NSManaged var imagesInverse: NSSet
    @NSManaged var photo: Asset?

}
