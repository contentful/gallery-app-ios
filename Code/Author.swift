//
//  Author.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreData

class Author: NSManagedObject, CDAPersistedEntry {

    @NSManaged var biography: String
    @NSManaged var identifier: String
    @NSManaged var name: String
    @NSManaged var twitterHandle: String
    @NSManaged var authorInverse: NSSet
    @NSManaged var createdEntries: NSOrderedSet
    @NSManaged var profilePhoto: Asset

}
