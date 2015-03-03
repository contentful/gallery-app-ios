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
        super.prepareForSegue(segue, sender: sender)

        if segue.identifier == SegueIdentifier.SingleImageSegue.rawValue {
            let imagesVC = segue.destinationViewController as ImagesViewController
            imagesVC.client = client
            imagesVC.images = images
            imagesVC.initialIndexPath = sender as? NSIndexPath
        }
    }

    func refresh() {
        client = dataManager.client
        
        dataManager.performSynchronization({ (error) -> Void in
            if error != nil && error.code != NSURLErrorNotConnectedToInternet {
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
            }

            self.images = sorted(self.dataManager.fetchGalleries().map { (gallery) in
                return (gallery, gallery.images.array as [Image])
            }) { $0.0.title < $1.0.title }
        })
    }

    override func viewWillAppear(animated: Bool) {
        refresh()
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SegueIdentifier.SingleImageSegue.rawValue, sender: indexPath)
    }
}
