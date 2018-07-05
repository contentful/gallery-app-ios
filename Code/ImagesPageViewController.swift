//
//  ImagesPageViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 17/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit
import Contentful

protocol SingleImageViewControllerDelegate: class {
    func updateCurrentIndex(_ index: Int)
}

class ImagesPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var client: Client?
    var gallery: Photo_Gallery?
    
    var images: [Image] {
        if let gallery = gallery {
            return gallery.images.array as! [Image]
        }
        return [Image]()
    }
    var initialIndex = 0
    weak var singleImageDelegate: SingleImageViewControllerDelegate?

    func updateCurrentIndex(_ index: Int) {
        if index < 0 || index > images.count {
            return
        }

        if (index == 0) {
            title = gallery?.title
        } else {
            let image = images[index - 1]
            title = image.title
        }

        if let delegate = singleImageDelegate {
            delegate.updateCurrentIndex(index - 1)
        }
    }

    func viewControllerWithIndex(index: Int) -> ImageDetailsViewController? {
        if index < 0 || index > images.count {
            return nil
        }

        let asset = index == 0 ? gallery?.coverImage : images[index - 1].photo
        let vc = ImageDetailsViewController()
        vc.pageViewController = self
        vc.view.tag = index

        var title = NSLocalizedString("Untitled", comment: "")
        var description = ""

        if (index == 0) {
            title = gallery?.title ?? title
            description = gallery?.galleryDescription ?? description
        } else {
            title = images[index - 1].imageCaption ?? title
            description = images[index - 1].imageCredits ?? description
        }

        vc.updateText("# \(title)\n\n\(description)")

        if let asset = asset, let urlString = asset.urlString {
            let size = UIScreen.main.bounds.size
            let imageOptions = [ImageOption.width(UInt(size.width)), ImageOption.height(UInt(size.height))]
            let url = try! urlString.url(with: imageOptions)

            vc.imageView.image = nil
            vc.imageView.af_setImage(withURL: url)
        }

        let _ = view.subviews.first?.gestureRecognizers?.map { (recognizer) -> Void in vc.scrollView.panGestureRecognizer.require(toFail: recognizer as UIGestureRecognizer) }

        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .black
        
        if let imageVC = viewControllerWithIndex(index: initialIndex + 1) {
            setViewControllers([imageVC], direction: .forward, animated: false) { (finished) in
                if finished {
                    self.updateCurrentIndex(self.initialIndex + 1)
                }
            }
        }
    }

    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewController.view.tag
        return viewControllerWithIndex(index: currentIndex + 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewController.view.tag
        return viewControllerWithIndex(index: currentIndex - 1)
    }

    // MARK: UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstVC = viewControllers?.first, completed {
            let currentIndex = firstVC.view.tag
            updateCurrentIndex(currentIndex)
        }
    }
}
