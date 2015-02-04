//
//  ViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 03/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    var dataManager: ContentfulDataManager? = nil
    var dataSource: CoreDataFetchDataSource? = nil
    var predicate: String? = nil

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

        let controller = dataManager?.fetchedResultsControllerForContentType(ContentfulDataManager.ImageContentTypeId, predicate: predicate, sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)])
        let collectionView = self.collectionView!
        dataSource = CoreDataFetchDataSource(fetchedResultsController: controller, collectionView: collectionView, cellIdentifier: NSStringFromClass(ViewController.self))

        dataSource?.cellConfigurator = { (cell, indexPath) -> Void in
            if let imageCell = cell as? ImageCell {
                if let image = self.dataSource?.objectAtIndexPath(indexPath) as? Image {
                    imageCell.imageView.offlineCaching_cda = true
                    imageCell.imageView.cda_setImageWithPersistedAsset(image.photo, client: self.dataManager?.client, size: collectionView.frame.size, placeholderImage: nil)
                }
            }
        }

        collectionView.dataSource = dataSource
        collectionView.pagingEnabled = true

        collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: NSStringFromClass(ViewController.self))

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = collectionView.frame.size
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .Horizontal
        collectionView.collectionViewLayout = layout
    }

    override func viewWillAppear(animated: Bool) {
        refresh()
    }
}

class ImageCell : UICollectionViewCell {
    let imageView: UIImageView

    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        imageView.contentMode = .ScaleAspectFit

        super.init(frame: frame)

        imageView.frame = self.bounds
        self.addSubview(imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
