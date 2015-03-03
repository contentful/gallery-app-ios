//
//  AnimatedFlowLayout.swift
//  Gallery
//
//  Created by Boris Bügling on 16/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class AnimatedFlowLayout: UICollectionViewFlowLayout {
    let π = CGFloat(M_PI)
    var indexPathsToAnimate = [NSIndexPath]()
    var showsHeader: Bool = false {
        didSet {
            if showsHeader {
                if let collectionView = collectionView {
                    headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: 160.0)
                    return
                }
            }

            headerReferenceSize = CGSizeZero
        }
    }

    func calculateItemSizeForBounds(bounds: CGRect) {
        let width = Int((bounds.width - 2.0) / 2)
        itemSize = CGSize(width: width, height: width)
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        indexPathsToAnimate.removeAll()
    }

    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = layoutAttributesForItemAtIndexPath(itemIndexPath)

        if contains(indexPathsToAnimate, itemIndexPath) {
            attr.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), π)
            attr.center = CGPoint(x: collectionView!.bounds.midX, y: collectionView!.bounds.maxY)

            indexPathsToAnimate.removeAtIndex(find(indexPathsToAnimate, itemIndexPath)!)
        }

        return attr
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if (newBounds != collectionView?.bounds) {
            calculateItemSizeForBounds(newBounds)
            return true
        }

        return false
    }

    override func prepareForCollectionViewUpdates(updateItems: [AnyObject]!) {
        super.prepareForCollectionViewUpdates(updateItems)

        indexPathsToAnimate += updateItems.map({ (element) -> NSIndexPath in
            return (element as UICollectionViewUpdateItem).indexPathAfterUpdate
        })
    }

    override func prepareLayout() {
        if let collectionView = collectionView {
            calculateItemSizeForBounds(collectionView.bounds)

            minimumInteritemSpacing = 1.0
            minimumLineSpacing = 1.0
        }

        super.prepareLayout()
    }
}
