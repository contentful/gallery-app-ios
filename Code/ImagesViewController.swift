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
    var metadataViewController: PostListMetadataViewController!
    
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
        collectionView?.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(ImagesViewController.self))

        metadataViewController = storyboard?.instantiateViewControllerWithIdentifier(ViewControllerStoryboardIdentifier.AuthorViewControllerId.rawValue) as PostListMetadataViewController
        metadataViewController.client = client
        metadataViewController.view.autoresizingMask = .None
        metadataViewController.view.frame.size.height = 160.0
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ImagesViewController.self), forIndexPath: indexPath) as ImageCell

        let image = images[indexPath.item]

        cell.backgroundColor = UIColor.darkGrayColor()
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
        return images.count
    }
}
