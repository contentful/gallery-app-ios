//
//  ImagesByGalleryViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 26/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit
import ZoomInteractiveTransition

class ImagesByGalleryViewController: UICollectionViewController, ZoomTransitionProtocol, SingleImageViewControllerDelegate {
    /**
     UIView, that will be used for zoom transition. Both source and destination view controllers need to implement this method, otherwise ZoomInteractiveTransition will not be performed.
     
     @param isSource Boolean, that is true if the view controller implementing this method is the source view controller of a transition.
     
     @return UIView, that will participate in transition.
     */
    @available(iOS 2.0, *)
    public func view(forZoomTransition isSource: Bool) -> UIView! {
        // FIXME:
        return UIView(frame: .zero)
    }



    lazy var dataManager = ContentfulDataManager()
    var selectedIndexPath: IndexPath?
    var transition: ZoomInteractiveTransition?

    var images: [(Photo_Gallery, [Image])] = [(Photo_Gallery, [Image])]() {
        didSet {
            if let layout = collectionView?.collectionViewLayout as? AnimatedFlowLayout {
                layout.showsHeader = true
            }

            collectionView?.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == SegueIdentifier.SingleImageSegue.rawValue {
            let indexPath = sender as! NSIndexPath
            let vc = segue.destination as! SingleImageViewController
            vc.client = dataManager.client
            vc.gallery = images[indexPath.section].0
            vc.initialIndex = indexPath.item
            vc.singleImageDelegate = self
        }
    }

    func refresh() {
        dataManager.performSynchronization() { result in
            switch result {
            case .success:
                self.images = self.dataManager.fetchGalleries().map { (gallery) in
                    return (gallery, gallery.images.array as! [Image])
                    }.sorted() { $0.0.title! < $1.0.title! }

            case .error(let error as NSError) where error.code != NSURLErrorNotConnectedToInternet:
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
            case .error(let error):
                break // TODO:
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addInfoButton()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)

        collectionView?.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        collectionView?.register(GalleryHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: GalleryHeaderView.self))
        
        transition = ZoomInteractiveTransition(navigationController: navigationController)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navBar = navigationController?.navigationBar {
            navBar.barStyle = .default
            navBar.barTintColor = nil
            navBar.tintColor = UIView().tintColor
            navBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.black ]
        }

        refresh()
    }

    // MARK: SingleImageViewControllerDelegate

    func updateCurrentIndex(index: Int) {
        if let selectedIndexPath = selectedIndexPath {
            self.selectedIndexPath = IndexPath(item: index, section: selectedIndexPath.section)
        } else {
            self.selectedIndexPath = IndexPath(item: index, section: 0)
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath as IndexPath) as! ImageCell

        let image = images[indexPath.section].1[indexPath.item]

        if let asset = image.photo {
            cell.imageView.image = nil

            // TODO:
//            cell.imageView.offlineCaching_cda = true
//            cell.imageView.cda_setImageWithPersistedAsset(asset, client: dataManager.client, size: UIScreen.mainScreen().bounds.size.screenSize(), placeholderImage: nil)
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images[section].1.count
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let gallery = images[indexPath.section].0
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: GalleryHeaderView.self), for: indexPath) as! GalleryHeaderView

            if let asset = gallery.coverImage {
                // TODO:
//                view.backgroundImageView.offlineCaching_cda = true
//                view.backgroundImageView.cda_setImageWithPersistedAsset(asset, client: dataManager.client, size: view.backgroundImageView.frame.size.screenSize(), placeholderImage: nil)
            }

            view.textLabel.text = gallery.title

            return view
        }

        return UICollectionReusableView()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return images.count
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: SegueIdentifier.SingleImageSegue.rawValue, sender: indexPath)
    }

    // MARK: ZoomTransitionProtocol

    func initialZoomViewSnapshot(fromProposedSnapshot snapshot: UIImageView!) -> UIImageView! {
        return UIImageView(image: viewForZoomTransition(isSource: true).dt_takeSnapshot())
    }

    func viewForZoomTransition(isSource: Bool) -> UIView! {
        if let selectedIndexPath = selectedIndexPath {
            if let collectionView = collectionView {
                if selectedIndexPath.item == -1 {
                    return collectionView
                }

                if let cell = collectionView.cellForItem(at: selectedIndexPath as IndexPath) as? ImageCell {
                    collectionView.scrollToItem(at: selectedIndexPath as IndexPath, at: .centeredVertically, animated: false)
                    return isSource ? cell.imageView : cell
                }

                if let cell = collectionView.dataSource?.collectionView(collectionView, cellForItemAt: selectedIndexPath as IndexPath) as? ImageCell {
                    collectionView.scrollToItem(at: selectedIndexPath as IndexPath, at: .centeredVertically, animated: false)
                    return isSource ? cell.imageView : cell
                }
            }
        }

        return nil
    }
}
