//
//  SyncInfo.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreData
import ContentfulPersistence

class SyncInfo: NSManagedObject, SyncSpacePersistable {

    @NSManaged var syncToken: String?
}
