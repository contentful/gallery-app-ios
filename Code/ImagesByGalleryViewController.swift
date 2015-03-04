//
//  ImagesByGalleryViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 26/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class ImagesByGalleryViewController: UICollectionViewController, ZoomTransitionProtocol, SingleImageViewControllerDelegate {
    lazy var dataManager = ContentfulDataManager()
    var selectedIndexPath: NSIndexPath?
    var transition: ZoomInteractiveTransition?

    var images: [(Photo_Gallery, [Image])] = [(Photo_Gallery, [Image])]() {
        didSet {
            if let layout = collectionView?.collectionViewLayout as? AnimatedFlowLayout {
                layout.showsHeader = true
            }

            collectionView?.reloadData()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        if segue.identifier == SegueIdentifier.SingleImageSegue.rawValue {
            let indexPath = sender as NSIndexPath
            let vc = segue.destinationViewController as SingleImageViewController
            vc.client = dataManager.client
            vc.gallery = images[indexPath.section].0
            vc.initialIndex = indexPath.item
            vc.singleImageDelegate = self
        }
    }

    func refresh() {
        dataManager.performSynchronization() { (error) -> Void in
            if error != nil && error.code != NSURLErrorNotConnectedToInternet {
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
            }

            self.images = sorted(self.dataManager.fetchGalleries().map { (gallery) in
                return (gallery, gallery.images.array as [Image])
            }) { $0.0.title < $1.0.title }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addInfoButton()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        collectionView?.registerClass(ImageCell.self, forCellWithReuseIdentifier: NSStringFromClass(self.dynamicType))
        collectionView?.registerClass(GalleryHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(self.dynamicType))
        
        transition = ZoomInteractiveTransition(navigationController: navigationController)
    }

    override func viewWillAppear(animated: Bool) {
        refresh()
    }

    // MARK: SingleImageViewControllerDelegate

    func updateCurrentIndex(index: Int) {
        if let selectedIndexPath = selectedIndexPath {
            self.selectedIndexPath = NSIndexPath(forItem: index, inSection: selectedIndexPath.section)
        } else {
            self.selectedIndexPath = NSIndexPath(forItem: index, inSection: 0)
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(self.dynamicType), forIndexPath: indexPath) as ImageCell

        let image = images[indexPath.section].1[indexPath.item]

        cell.imageView.image = nil
        cell.imageView.offlineCaching_cda = true
        cell.imageView.cda_setImageWithPersistedAsset(image.photo, client: dataManager.client, size: UIScreen.mainScreen().bounds.size.screenSize(), placeholderImage: nil)

        return cell
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images[section].1.count
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let gallery = images[indexPath.section].0
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: NSStringFromClass(self.dynamicType), forIndexPath: indexPath) as GalleryHeaderView

            view.backgroundImageView.offlineCaching_cda = true
            view.backgroundImageView.cda_setImageWithPersistedAsset(gallery.coverImage, client: dataManager.client, size: view.backgroundImageView.frame.size.screenSize(), placeholderImage: nil)
            view.textLabel.text = gallery.title

            return view
        }

        return UICollectionReusableView()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return images.count
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        performSegueWithIdentifier(SegueIdentifier.SingleImageSegue.rawValue, sender: indexPath)
    }

    // MARK: ZoomTransitionProtocol

    func initialZoomViewSnapshotFromProposedSnapshot(snapshot: UIImageView!) -> UIImageView! {
        return UIImageView(image: viewForZoomTransition(true).dt_takeSnapshot())
    }

    func viewForZoomTransition(isSource: Bool) -> UIView! {
        if let selectedIndexPath = selectedIndexPath {
            if let collectionView = collectionView {
                if let cell = collectionView.cellForItemAtIndexPath(selectedIndexPath) as? ImageCell {
                    return cell.imageView
                }

                if let cell = collectionView.dataSource?.collectionView(collectionView, cellForItemAtIndexPath: selectedIndexPath) as? ImageCell {
                    return cell.imageView
                }
            }
        }

        return nil
    }
}
