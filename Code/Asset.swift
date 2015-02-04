//
//  Asset.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation
import CoreData

class Asset: NSManagedObject, CDAPersistedAsset {

    @NSManaged var height: NSNumber
    @NSManaged var identifier: String
    @NSManaged var internetMediaType: String
    @NSManaged var url: String
    @NSManaged var width: NSNumber
    @NSManaged var coverImage_79h5TZwqOWy0ygOKGs2Wky_Inverse: NSSet
    @NSManaged var images_79h5TZwqOWy0ygOKGs2Wky_Inverse: NSSet
    @NSManaged var photo_1xYw5JsIecuGE68mmGMg20_Inverse: NSSet
    @NSManaged var profilePhoto_38nK0gXXIccQ2IEosyAg6C_Inverse: NSSet

}
