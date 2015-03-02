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

    private var fakeSections = 0
    var images: [(Photo_Gallery, [Image])] = [(Photo_Gallery, [Image])]() {
        willSet {
            if collectionView?.numberOfSections() == 0 {
                fakeSections = newValue.count
                collectionView?.insertSections(NSIndexSet(indexesInRange: NSMakeRange(0, fakeSections)))
            }
        }

        didSet {
            if collectionView?.numberOfItemsInSection(0) > 0 {
                collectionView?.reloadData()
                return
            }

            let indexPaths = toArray(enumerate(images)).map { (section, tuple) -> [NSIndexPath] in
                let images = toArray(enumerate(tuple.1))
                return images.map { (index, image) -> NSIndexPath in
                    return NSIndexPath(forItem: index, inSection: section)
                }
            }.reduce([], +)
            collectionView?.insertItemsAtIndexPaths(indexPaths)
        }
    }

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

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SegueIdentifier.SingleImageSegue.rawValue, sender: indexPath.item)
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: NSStringFromClass(ImagesViewController.self), forIndexPath: indexPath) as UICollectionReusableView
            view.addSubview(metadataViewController.view)
            return view
        }

        return UICollectionReusableView()
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count > 0 ? images[section].1.count : 0
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return images.count > 0 ? images.count : fakeSections
    }
}
