//
//  ImagesByGalleryViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 26/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class ImagesByGalleryViewController: ImagesViewController, UIPopoverPresentationControllerDelegate, GalleryListDelegate {
    lazy var dataManager = ContentfulDataManager()

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.SingleImageSegue.rawValue {
            let gallery = sender as Photo_Gallery

            let imagesVC = segue.destinationViewController as ImagesViewController
            imagesVC.client = dataManager.client
            imagesVC.images = gallery.images.array as [Image]
            imagesVC.title = gallery.title

            if let author = gallery.author {
                imagesVC.metadataViewController.metadata = PostListMetadata(body: author.biography, photo: author.profilePhoto, title: author.name)
                imagesVC.metadataViewController.numberOfPosts = imagesVC.images.count
            }
        }
    }

    @IBAction func presentSelection(sender: UIBarButtonItem) {
        var popoverContent = storyboard?.instantiateViewControllerWithIdentifier(TableViewControllerStoryboardIdentifier.GalleryListViewControllerId.rawValue) as GalleryListViewController
        popoverContent.client = dataManager.client
        popoverContent.delegate = self
        popoverContent.galleries = dataManager.fetchGalleries()
        popoverContent.modalPresentationStyle = .Popover
        popoverContent.preferredContentSize = CGSize(width: view.frame.size.width - 20.0, height: view.frame.size.height - 100.0)

        var popover = popoverContent.popoverPresentationController
        popover?.backgroundColor = UIColor.clearColor()
        popover?.barButtonItem = sender
        popover?.delegate = self

        presentViewController(popoverContent, animated: true, completion: nil)
    }

    func refresh() {
        client = dataManager.client
        metadataViewController.client = dataManager.client
        
        dataManager.performSynchronization({ (error) -> Void in
            if error != nil && error.code != NSURLErrorNotConnectedToInternet {
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
            }

            self.images = self.dataManager.fetchImages()
        })
    }

    override func viewWillAppear(animated: Bool) {
        refresh()
    }

    // MARK: GalleryListDelegate

    func didSelectAllImages() {
        if let layout = collectionView?.collectionViewLayout as? AnimatedFlowLayout {
            layout.showsHeader = false
        }

        images = dataManager.fetchImages()
    }

    func didSelectGallery(gallery: Photo_Gallery) {
        if let layout = collectionView?.collectionViewLayout as? AnimatedFlowLayout {
            layout.showsHeader = true
        }

        images = gallery.images.array as [Image]

        if let author = gallery.author {
            metadataViewController.metadata = PostListMetadata(body: author.biography, photo: author.profilePhoto, title: author.name)
            metadataViewController.numberOfPosts = gallery.images.count
        }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let gallery = images[indexPath.row].imagesInverse.anyObject() as? Photo_Gallery {
            performSegueWithIdentifier(SegueIdentifier.SingleImageSegue.rawValue, sender: gallery)
        }
    }

    // MARK: UIPopoverPresentationControllerDelegate

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
