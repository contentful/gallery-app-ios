//
//  ImagesViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 16/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import Foundation

func toArray<T, U where U == T.Generator.Element>(sequence: EnumerateSequence<T>) -> [(Int, U)] {
    var generator = sequence.generate()
    var result = [(Int, U)]()

    while let element = generator.next() {
        result.append(element)
    }

    return result
}

class ImagesViewController: UICollectionViewController {
    weak var client: CDAClient? = nil
    
    var images: [Image] = [Image]() {
        willSet {
            // Needed to establish that the collection view initially contains no items
            let unused = collectionView?.numberOfItemsInSection(0)
        }

        didSet {
            let indexPaths = toArray(enumerate(images)).map { (index, image) -> NSIndexPath in
                return NSIndexPath(forItem: index, inSection: 0)
            }
            collectionView?.insertItemsAtIndexPaths(indexPaths)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.registerClass(ImageCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImagesViewController.self))

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100.0, height: 100.0)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        collectionView?.collectionViewLayout = layout
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ImagesViewController.self), forIndexPath: indexPath) as ImageCell

        let image = images[indexPath.item]

        cell.imageView.offlineCaching_cda = true
        cell.imageView.cda_setImageWithPersistedAsset(image.photo, client: client, size: cell.frame.size.screenSize(), placeholderImage: nil)

        return cell
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
}
