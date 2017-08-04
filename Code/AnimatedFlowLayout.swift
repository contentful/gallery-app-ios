//
//  AnimatedFlowLayout.swift
//  Gallery
//
//  Created by Boris Bügling on 16/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class AnimatedFlowLayout: UICollectionViewFlowLayout {
    var indexPathsToAnimate = [IndexPath]()
    var showsHeader: Bool = false {
        didSet {
            if showsHeader {
                if let collectionView = collectionView {
                    headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: 160.0)
                    return
                }
            }

            headerReferenceSize = .zero
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

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = layoutAttributesForItem(at: itemIndexPath)

        if let attr = attr, indexPathsToAnimate.contains(itemIndexPath) {
            attr.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).rotated(by: CGFloat(Double.pi))
            attr.center = CGPoint(x: collectionView!.bounds.midX, y: collectionView!.bounds.maxY)

            indexPathsToAnimate.remove(at: indexPathsToAnimate.index(of: itemIndexPath)!)
        }

        return attr
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if (newBounds != collectionView?.bounds) {
            calculateItemSizeForBounds(bounds: newBounds)
            return true
        }

        return false
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        indexPathsToAnimate += updateItems.map { (element) -> IndexPath? in
            return (element as UICollectionViewUpdateItem).indexPathAfterUpdate
        }.compactMap { $0 }
    }

    override func prepare() {
        if let collectionView = collectionView {
            calculateItemSizeForBounds(bounds: collectionView.bounds)

            minimumInteritemSpacing = 1.0
            minimumLineSpacing = 1.0
        }

        super.prepare()
    }
}
