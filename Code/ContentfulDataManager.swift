//
//  ContentfulDataManager.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import CoreData

class ContentfulDataManager: NSObject {
    class var AuthorContentTypeId: String { return "38nK0gXXIccQ2IEosyAg6C" }
    class var GalleryContentTypeId: String { return "79h5TZwqOWy0ygOKGs2Wky" }
    class var ImageContentTypeId: String { return "1xYw5JsIecuGE68mmGMg20" }

    var client: CDAClient { return manager.client }
    var manager: CoreDataManager
    var notificationToken: NSObjectProtocol? = nil

    deinit {
        if let token = notificationToken {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
    }

    func fetchedResultsControllerForContentType(identifier: String, predicate: String?, sortDescriptors: [NSSortDescriptor]) -> NSFetchedResultsController {
        let fetchRequest = manager.fetchRequestForEntriesOfContentTypeWithIdentifier(identifier, matchingPredicate: predicate)
        fetchRequest.sortDescriptors = sortDescriptors

        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: manager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    override init() {
        let configuration = CDAConfiguration.defaultConfiguration()
        configuration.userAgent = "Contentful Gallery App/1.0";

        let client = CDAClient(spaceKey: NSUserDefaults.standardUserDefaults().stringForKey(AppDelegate.SpaceKey), accessToken: NSUserDefaults.standardUserDefaults().stringForKey(AppDelegate.AccessToken), configuration:configuration)
        manager = CoreDataManager(client: client, dataModelName: "Gallery")

        manager.classForAssets = Asset.self
        manager.classForSpaces = SyncInfo.self

        manager.setClass(Author.self, forEntriesOfContentTypeWithIdentifier: ContentfulDataManager.AuthorContentTypeId)
        manager.setClass(PhotoGallery.self, forEntriesOfContentTypeWithIdentifier: ContentfulDataManager.GalleryContentTypeId)
        manager.setClass(Image.self, forEntriesOfContentTypeWithIdentifier: ContentfulDataManager.ImageContentTypeId)

        super.init()

        notificationToken = NSNotificationCenter.defaultCenter().addObserverForName(AppDelegate.SpaceChangedNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (note: NSNotification?) -> Void in
            if let note = note {
                self.manager.deleteAll()

                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setValue(note.userInfo![AppDelegate.SpaceKey], forKey: AppDelegate.SpaceKey)
                defaults.setValue(note.userInfo![AppDelegate.AccessToken], forKey: AppDelegate.AccessToken)

                let keyWindow = UIApplication.sharedApplication().keyWindow!
                keyWindow.rootViewController = keyWindow.rootViewController?.storyboard?.instantiateInitialViewController() as? UIViewController
            }
        })
    }

    func performSynchronization(completion: (NSError!) -> Void) {
        manager.performSynchronizationWithSuccess({ () -> Void in
            completion(nil)
            }, failure: { (response, error) -> Void in
                completion(error)
        })
    }
}
