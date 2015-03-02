//
//  ImagesByGalleryViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 26/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class ImagesByGalleryViewController: ImagesViewController {
    lazy var dataManager = ContentfulDataManager()

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.SingleImageSegue.rawValue {
            let gallery = sender as Photo_Gallery
            let images = gallery.images.array as [Image]

            let imagesVC = segue.destinationViewController as ImagesViewController
            imagesVC.client = dataManager.client
            imagesVC.images = [(gallery, images)]
            imagesVC.title = gallery.title
        }
    }

    func refresh() {
        client = dataManager.client
        
        dataManager.performSynchronization({ (error) -> Void in
            if error != nil && error.code != NSURLErrorNotConnectedToInternet {
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
            }

            self.images = self.dataManager.fetchGalleries().map { (gallery) in
                return (gallery, gallery.images.array as [Image])
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let layout = collectionView?.collectionViewLayout as? AnimatedFlowLayout {
            layout.showsHeader = true
        }
    }

    override func viewWillAppear(animated: Bool) {
        refresh()
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let gallery = images[indexPath.section].0
        performSegueWithIdentifier(SegueIdentifier.SingleImageSegue.rawValue, sender: gallery)
    }
}
