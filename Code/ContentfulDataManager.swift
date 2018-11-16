//
//  ContentfulDataManager.swift
//  Gallery
//
//  Created by Boris Bügling on 04/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import CoreData
import Contentful
import ContentfulPersistence
import Keys

class ContentfulDataManager {

    let coreDataStore: CoreDataStore
    let managedObjectContext: NSManagedObjectContext
    let contentfulSynchronizer: SynchronizationManager

    static let storeURL = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask).last?.appendingPathComponent("Gallery.sqlite")

    static func setupManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let modelURL = Bundle(for: ContentfulDataManager.self).url(forResource: "Gallery", withExtension: "momd")!

        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: ContentfulDataManager.storeURL!, options: nil)
        } catch {
            fatalError()
        }

        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }

    func fetchGalleries(predicate: String? = nil) -> [Photo_Gallery] {
        let fetchPredicate = predicate != nil ? NSPredicate(format: predicate!) : NSPredicate(value: true)
        return try! coreDataStore.fetchAll(type: Photo_Gallery.self, predicate: fetchPredicate)
    }

    func fetchImages(predicate: String? = nil) -> [Image] {

        let fetchPredicate = predicate != nil ? NSPredicate(format: predicate!) : NSPredicate(value: true)
        return try! coreDataStore.fetchAll(type: Image.self, predicate: fetchPredicate)
    }

    init() {
        let model = PersistenceModel(spaceType: SyncInfo.self,
                                     assetType: Asset.self,
                                     entryTypes: [Image.self, Photo_Gallery.self, Author.self])

        let managedObjectContext = ContentfulDataManager.setupManagedObjectContext()
        let coreDataStore  = CoreDataStore(context: managedObjectContext)
        self.managedObjectContext = managedObjectContext
        self.coreDataStore = coreDataStore
        let keys = GalleryKeys()
        let client = Client(spaceId: keys.gallerySpaceId,
                            accessToken: keys.galleryAccessToken)
        let contentfulSynchronizer = SynchronizationManager(client: client,
                                                            localizationScheme: .default,
                                                            persistenceStore: coreDataStore,
                                                            persistenceModel: model)
        self.contentfulSynchronizer = contentfulSynchronizer
    }

    func performSynchronization(completion: @escaping ResultsHandler<SyncSpace>) {
        contentfulSynchronizer.sync { result in
            completion(result)
        }
    }
}
