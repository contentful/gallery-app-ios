//
//  SyncInfo.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreData
import ContentfulDeliveryAPI

class SyncInfo: NSManagedObject, CDAPersistedSpace {

    @NSManaged var lastSyncTimestamp: NSDate
    @NSManaged var syncToken: String

}
