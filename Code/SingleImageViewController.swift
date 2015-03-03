//
//  SingleImageViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 17/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class SingleImageViewController: ImagesViewController {
    var lastIndexPath = NSIndexPath(forItem: 0, inSection: 0)

    func currentIndexPath() -> NSIndexPath {
        let indexPath = collectionView!.indexPathForItemAtPoint(CGPoint(x: collectionView!.contentOffset.x + 5.0, y: 100.0))
        return indexPath ?? NSIndexPath(forItem: 0, inSection: 0)
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)

        if let collectionView = collectionView {
            let layout = collectionView.collectionViewLayout as UICollectionViewFlowLayout

            var size = collectionView.frame.size
            size.height -= navigationController!.navigationBar.frame.size.height
            layout.itemSize = size

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                collectionView.scrollToItemAtIndexPath(self.lastIndexPath, atScrollPosition: .Left, animated: false)
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let collectionView = collectionView {
            let layout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
            layout.minimumInteritemSpacing = 0.0
            layout.minimumLineSpacing = 0.0

            var size = collectionView.frame.size
            size.height -= 44.0
            layout.itemSize = size

            collectionView.pagingEnabled = true
        }
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)

        lastIndexPath = currentIndexPath()
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }

    // MARK: UIScrollViewDelegate

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let image = images[currentIndexPath().section].1[currentIndexPath().item]

        title = image.title
    }
}
