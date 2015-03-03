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

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let collectionView = imagesVC.collectionView {
                    let index = sender as Int
                    collectionView.setContentOffset(CGPoint(x: index * Int(collectionView.frame.size.width), y: 0), animated: false)
                }
            })
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
        let offset = (0..<indexPath.section).map { collectionView.numberOfItemsInSection($0) }.reduce(0, +) + indexPath.item
        performSegueWithIdentifier(SegueIdentifier.SingleImageSegue.rawValue, sender: offset)
    }
}
