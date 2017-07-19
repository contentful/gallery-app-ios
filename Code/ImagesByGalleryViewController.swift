//
//  ImagesByGalleryViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 26/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit
import AlamofireImage

class ImagesByGalleryViewController: UICollectionViewController, SingleImageViewControllerDelegate {

    lazy var dataManager = ContentfulDataManager()
    var selectedIndexPath: IndexPath?

    var galleries: [Photo_Gallery] = [Photo_Gallery]() {
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
            vc.gallery = galleries[indexPath.section]
            vc.initialIndex = indexPath.item
            vc.singleImageDelegate = self
        }
    }

    func refresh() {
        dataManager.performSynchronization() { result in
            switch result {
            case .success:
                self.galleries = self.dataManager.fetchGalleries().sorted() { $0.title! < $1.title! }
                self.collectionView?.reloadData()

            case .error(let error as NSError) where error.code != NSURLErrorNotConnectedToInternet:
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
            case .error(let error):
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addInfoButton()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)

        collectionView?.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        collectionView?.register(GalleryHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: GalleryHeaderView.self))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("ImagesByGalleryViewController appearing")
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

        let image = galleries[indexPath.section].images[indexPath.item] as? Image

        if let asset = image?.photo, let urlString = asset.urlString, let url = URL(string: urlString) {
            cell.imageView.image = nil

            cell.imageView.af_setImage(withURL: url,
                                       imageTransition: .crossDissolve(0.5),
                                       runImageTransitionIfCached: true)
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleries[section].images.count
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let gallery = galleries[indexPath.section]
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: GalleryHeaderView.self), for: indexPath) as! GalleryHeaderView

            if let asset = gallery.coverImage, let urlString = asset.urlString, let url = URL(string: urlString) {
                view.backgroundImageView.af_setImage(withURL: url,
                                                     imageTransition: .crossDissolve(0.5),
                                                     runImageTransitionIfCached: true)
            }

            view.textLabel.text = gallery.title

            return view
        }

        return UICollectionReusableView()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return galleries.count
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: SegueIdentifier.SingleImageSegue.rawValue, sender: indexPath)
    }
}
