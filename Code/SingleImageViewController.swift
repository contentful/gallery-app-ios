//
//  SingleImageViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 17/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class SingleImageViewController: ImagesViewController {
    var currentIndex = 0

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)

        if let collectionView = collectionView {
            let layout = collectionView.collectionViewLayout as UICollectionViewFlowLayout

            var size = collectionView.frame.size
            size.height -= navigationController!.navigationBar.frame.size.height
            layout.itemSize = size

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                collectionView.setContentOffset(CGPoint(x: self.currentIndex * Int(collectionView.frame.size.width), y: Int(collectionView.contentOffset.y)), animated: false)
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

        currentIndex = Int(collectionView!.contentOffset.x / collectionView!.frame.size.width)
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }

    // MARK: UIScrollViewDelegate

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)

        if index >= 0 && index < images[0].1.count {
            let image = images[0].1[index]

            title = image.title
        }
    }
}
