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

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        indexPathsToAnimate.removeAll()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        itemSize = CGSize(width: 100.0, height: 100.0)
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
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

    override func prepareForCollectionViewUpdates(updateItems: [AnyObject]!) {
        super.prepareForCollectionViewUpdates(updateItems)

        indexPathsToAnimate += updateItems.map({ (element) -> NSIndexPath in
            return (element as UICollectionViewUpdateItem).indexPathAfterUpdate
        })
    }
}
