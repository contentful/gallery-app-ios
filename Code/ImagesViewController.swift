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
    weak var client: CDAClient?

    var images: [(Photo_Gallery, [Image])] = [(Photo_Gallery, [Image])]() {
        didSet {
            if let layout = collectionView?.collectionViewLayout as? AnimatedFlowLayout {
                layout.showsHeader = true
            }

            collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addInfoButton()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        collectionView?.registerClass(ImageCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImagesViewController.self))
        collectionView?.registerClass(GalleryHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(ImagesViewController.self))
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ImagesViewController.self), forIndexPath: indexPath) as ImageCell

        let image = images[indexPath.section].1[indexPath.item]

        cell.imageView.image = nil
        cell.imageView.offlineCaching_cda = true
        cell.imageView.cda_setImageWithPersistedAsset(image.photo, client: client, size: CGSize(width: 400.0, height: 400.0).screenSize(), placeholderImage: nil)

        return cell
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let gallery = images[indexPath.section].0
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: NSStringFromClass(ImagesViewController.self), forIndexPath: indexPath) as GalleryHeaderView

            view.backgroundImageView.offlineCaching_cda = true
            view.backgroundImageView.cda_setImageWithPersistedAsset(gallery.coverImage, client: client, size: view.backgroundImageView.frame.size.screenSize(), placeholderImage: nil)
            view.textLabel.text = gallery.title

            return view
        }

        return UICollectionReusableView()
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images[section].1.count
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return images.count
    }
}
