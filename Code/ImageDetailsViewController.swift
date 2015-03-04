//
//  ImageDetailsViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 03/03/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

let metaInformationHeight = CGFloat(100.0)

class ImageDetailsViewController: UIViewController, UIScrollViewDelegate {
    let captionLabel = UILabel(frame: CGRectZero)
    let creditsLabel = UILabel(frame: CGRectZero)
    let imageView = UIImageView(frame: CGRectZero)
    var kvoController: FBKVOController?
    let metaInformationContainer = UIView(frame: CGRectZero)
    weak var pageViewController: UIPageViewController?
    let scrollView = UIScrollView(frame: CGRectZero)

    deinit {
        kvoController?.unobserve(imageView)
    }

    override init() {
        super.init(nibName: nil, bundle: nil)

        kvoController = FBKVOController(observer: self)
        kvoController?.observe(imageView, keyPath: "image", options: .New, context: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func computeFrames() {
        if UIInterfaceOrientationIsPortrait(self.interfaceOrientation) {
            scrollView.frame.size.height = view.frame.size.height - metaInformationHeight
            metaInformationContainer.frame.size.height = metaInformationHeight
        } else {
            scrollView.frame.size.height = view.frame.size.height
            metaInformationContainer.frame.origin.y = view.frame.maxY
            metaInformationContainer.frame.size.height = metaInformationHeight
        }

        creditsLabel.frame.size.height = metaInformationContainer.frame.size.height - captionLabel.frame.size.height
        metaInformationContainer.frame.origin.y = scrollView.frame.maxY
    }

    func defaultZoom() {
        if let image = imageView.image {
            let xZoom = image.size.width / scrollView.frame.size.width
            let yZoom = image.size.height / scrollView.frame.size.height
            scrollView.zoomScale = max(xZoom, yZoom)
            scrollViewDidZoom(scrollView)
        }
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)

        UIView.animateWithDuration(0.1) {
            self.computeFrames()
        }
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        updateImage(imageView.image)
    }

    func statusBarStyleForBackgroundColor(color: UIColor) -> UIBarStyle {
        let componentColors = CGColorGetComponents(color.CGColor)

        var darknessScore = componentColors[0] * 255 * 299
        darknessScore += componentColors[1] * 255 * 587
        darknessScore += componentColors[2] * 255 * 114
        darknessScore /= 1000.0

        return (darknessScore >= 125.0) ? .Default : .Black
    }

    func updateImage(image: UIImage?) {
        if image == nil {
            view.backgroundColor = UIColor.whiteColor()
            imageView.backgroundColor = UIColor.whiteColor()
            captionLabel.textColor = UIColor.blackColor()
            creditsLabel.textColor = UIColor.blackColor()
            return
        }

        defaultZoom()

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let size = CGSize(width: 100.0, height: 100.0)

            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            self.imageView.image?.drawInRect(CGRect(origin: CGPointZero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let chromoplast = SOZOChromoplast(image: scaledImage)

            dispatch_async(dispatch_get_main_queue()) {
                self.view.backgroundColor = chromoplast.dominantColor
                self.imageView.backgroundColor = chromoplast.dominantColor
                self.captionLabel.textColor = chromoplast.firstHighlight
                self.creditsLabel.textColor = chromoplast.secondHighlight

                self.updateNavigationBar(false)
            }
        }
    }

    func updateNavigationBar(force: Bool) {
        if let viewController = self.pageViewController {
            if !force && viewController.viewControllers[0] !== self {
                return
            }

            if let navBar = viewController.navigationController?.navigationBar {
                navBar.barStyle = statusBarStyleForBackgroundColor(view.backgroundColor!)
                navBar.barTintColor = view.backgroundColor
                navBar.tintColor = captionLabel.textColor
                navBar.titleTextAttributes = [ NSForegroundColorAttributeName: captionLabel.textColor ]
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [captionLabel, creditsLabel, metaInformationContainer, imageView, scrollView].map { (view) -> () in
            view.autoresizingMask = .FlexibleWidth
            view.frame.size.width = self.view.frame.size.width
        }

        captionLabel.frame = CGRectInset(captionLabel.frame, 20.0, 0.0)
        captionLabel.frame.size.height = 30.0
        captionLabel.font = UIFont.boldTitleFont().fontWithSize(24.0)

        creditsLabel.font = UIFont.bodyTextFont()
        creditsLabel.frame = CGRectInset(creditsLabel.frame, 20.0, 0.0)
        creditsLabel.frame.origin.y = captionLabel.frame.maxY
        creditsLabel.numberOfLines = 2

        imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFit

        metaInformationContainer.addSubview(captionLabel)
        metaInformationContainer.addSubview(creditsLabel)

        scrollView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.addSubview(imageView)

        let recognizer = UITapGestureRecognizer(target: self, action: "doubleTapped")
        recognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(recognizer)

        view.addSubview(metaInformationContainer)
        view.addSubview(scrollView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        computeFrames()
        defaultZoom()
        updateNavigationBar(true)
    }

    // MARK: Actions

    func doubleTapped() {
        UIView.animateWithDuration(0.1) {
            self.defaultZoom()
        }
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidZoom(scrollView: UIScrollView) {
        let innerFrame = imageView.frame
        let scrollerBounds = scrollView.bounds

        if (innerFrame.size.width < scrollerBounds.size.width) || (innerFrame.size.height < scrollerBounds.size.height) {
            scrollView.contentOffset = CGPoint(x: imageView.center.x - (scrollerBounds.size.width / 2), y: imageView.center.y - (scrollerBounds.size.height / 2))
        }

        var insets = UIEdgeInsetsZero

        if (scrollerBounds.size.width > innerFrame.size.width) {
            insets.left = (scrollerBounds.size.width - innerFrame.size.width) / 2
            insets.right = -insets.left
        }

        if (scrollerBounds.size.height > innerFrame.size.height) {
            insets.top = (scrollerBounds.size.height - innerFrame.size.height) / 2
            insets.bottom = -insets.top
        }

        scrollView.contentInset = insets
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
