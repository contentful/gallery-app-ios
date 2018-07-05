//
//  ImagesByGalleryViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 26/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit
import AlamofireImage
import Contentful

class ImagesByGalleryViewController: UICollectionViewController,
                                     UINavigationControllerDelegate,
                                     SingleImageViewControllerDelegate {

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


    func refresh() {
        dataManager.performSynchronization() { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success:
                strongSelf.galleries = strongSelf.dataManager.fetchGalleries().sorted() { $0.title! < $1.title! }
                strongSelf.collectionView?.reloadData()

            case .error(let error as NSError) where error.code != NSURLErrorNotConnectedToInternet:
                strongSelf.galleries = strongSelf.dataManager.fetchGalleries().sorted() { $0.title! < $1.title! }
                strongSelf.collectionView?.reloadData()

                strongSelf.showAlertController(for: error)
            case .error(let error):
                strongSelf.galleries = strongSelf.dataManager.fetchGalleries().sorted() { $0.title! < $1.title! }
                strongSelf.collectionView?.reloadData()

                strongSelf.showAlertController(for: error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addInfoButton()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)

        collectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: ImageCollectionViewCell.self))
        collectionView?.register(GalleryHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: GalleryHeaderView.self))

        refresh()
    }

    // MARK: Private

    func showAlertController(for error: Error) {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: SingleImageViewControllerDelegate

    func updateCurrentIndex(_ index: Int) {
        if let selectedIndexPath = selectedIndexPath {
            self.selectedIndexPath = IndexPath(item: index, section: selectedIndexPath.section)
        } else {
            self.selectedIndexPath = IndexPath(item: index, section: 0)
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCollectionViewCell.self), for: indexPath as IndexPath) as! ImageCollectionViewCell

        let image = galleries[indexPath.section].images[indexPath.item] as? Image

        if let asset = image?.photo, let urlString = asset.urlString {
            let size = UIScreen.main.bounds.size
            let imageOptions = [ImageOption.width(UInt(size.width)), ImageOption.height(UInt(size.height))]
            let url = try! urlString.url(with: imageOptions)

            cell.imageView.image = nil
            cell.imageView.af_setImage(withURL: url,
                                       imageTransition: .crossDissolve(0.2))
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
                                                     imageTransition: .crossDissolve(0.2))
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

        let imagesPageViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagesPageViewController") as! ImagesPageViewController
        imagesPageViewController.gallery = galleries[indexPath.section]
        imagesPageViewController.initialIndex = indexPath.row
        navigationController?.pushViewController(imagesPageViewController, animated: true)
    }

    // MARK: UINavigationControllerDelegate 

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController == self else { return }
        let navBar = navigationController.navigationBar
        navBar.barStyle = .default
        navBar.barTintColor = nil
        navBar.tintColor = UIView().tintColor
        navBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
}
