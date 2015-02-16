//
//  GalleriesViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 03/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class GalleriesViewController: UICollectionViewController {
    var dataManager: ContentfulDataManager? = nil
    var dataSource: CoreDataFetchDataSource? = nil
    var predicate: String? = nil

    lazy var kvoController: FBKVOController = FBKVOController(observer: self)

    deinit {
        kvoController.unobserveAll()
    }

    func refresh() {
        dataManager?.performSynchronization({ (error) -> Void in
            if error != nil && error.code != NSURLErrorNotConnectedToInternet {
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
            }

            self.dataSource?.performFetch()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataManager = ContentfulDataManager()

        let controller = dataManager?.fetchedResultsControllerForContentType(ContentfulDataManager.GalleryContentTypeId, predicate: predicate, sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)])
        let collectionView = self.collectionView!
        dataSource = CoreDataFetchDataSource(fetchedResultsController: controller, collectionView: collectionView, cellIdentifier: NSStringFromClass(GalleriesViewController.self))

        dataSource?.cellConfigurator = { (cell, indexPath) -> Void in
            if let imageCell = cell as? ImageCell {
                if let gallery = self.dataSource?.objectAtIndexPath(indexPath) as? PhotoGallery {
                    imageCell.imageView.offlineCaching_cda = true
                    imageCell.imageView.cda_setImageWithPersistedAsset(gallery.coverImage, client: self.dataManager?.client, size: collectionView.frame.size, placeholderImage: nil)
                    imageCell.titleLabel.text = gallery.title

                    self.kvoController.observe(imageCell.imageView, keyPath: "image", options: .New,
                        block: { (observer, object, change) -> Void in
                            let chromoplast = SOZOChromoplast(image: imageCell.imageView.image)
                            imageCell.imageView.backgroundColor = chromoplast.dominantColor

                            imageCell.titleLabel.shadowColor = chromoplast.colors.first as? UIColor
                            imageCell.titleLabel.shadowOffset = CGSize(width: 1.0, height: 1.0)
                            imageCell.titleLabel.textColor = chromoplast.colors.last as UIColor
                    })
                }
            }
        }

        collectionView.dataSource = dataSource
        collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: NSStringFromClass(GalleriesViewController.self))

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.size.width, height: 200.0)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        collectionView.collectionViewLayout = layout
    }

    override func viewWillAppear(animated: Bool) {
        refresh()
    }
}
