//
//  ImageDetailsViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 03/03/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit
import KVOController
import SOZOChromoplast

let metaInformationHeight = CGFloat(100.0)

class ImageDetailsViewController: UIViewController, UIScrollViewDelegate {
    var chromoplast: SOZOChromoplast?
    let imageView = UIImageView(frame: CGRectZero)
    var kvoController: FBKVOController?
    let metaInformationView = UITextView(frame: CGRectZero)
    weak var pageViewController: UIPageViewController?
    let scrollView = UIScrollView(frame: CGRectZero)

    deinit {
        kvoController?.unobserve(imageView)
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)

        kvoController = FBKVOController(observer: self)
        kvoController?.observe(imageView, keyPath: "image", options: .New, context: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func computeFrames() {
        if UIInterfaceOrientationIsPortrait(self.interfaceOrientation) {
            scrollView.frame.size.height = view.frame.size.height - metaInformationHeight
            metaInformationView.frame.size.height = metaInformationHeight
        } else {
            scrollView.frame.size.height = view.frame.size.height
            metaInformationView.frame.origin.y = view.frame.maxY
            metaInformationView.frame.size.height = metaInformationHeight
        }

        metaInformationView.frame.origin.y = scrollView.frame.maxY
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

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
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
            return
        }

        defaultZoom()

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let size = CGSize(width: 100.0, height: 100.0)

            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            self.imageView.image?.drawInRect(CGRect(origin: CGPointZero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            self.chromoplast = SOZOChromoplast(image: scaledImage)

            dispatch_async(dispatch_get_main_queue()) {
                self.view.backgroundColor = self.chromoplast!.dominantColor
                self.imageView.backgroundColor = self.chromoplast!.dominantColor

                let mutableText = self.metaInformationView.attributedText.mutableCopy() as! NSMutableAttributedString

                let firstLine = mutableText.string.rangeOfString("\n")!
                let range = NSMakeRange(0, (mutableText.string.startIndex).distanceTo(firstLine.startIndex))

                mutableText.addAttribute(NSForegroundColorAttributeName, value: self.chromoplast!.firstHighlight!, range: range)
                mutableText.addAttribute(NSForegroundColorAttributeName, value: self.chromoplast!.secondHighlight!, range: NSMakeRange(range.length, (firstLine.endIndex).distanceTo(mutableText.string.endIndex)))

                self.metaInformationView.attributedText = mutableText

                self.updateNavigationBar(false)
            }
        }
    }

    func updateNavigationBar(force: Bool) {
        if let viewController = self.pageViewController, firstVC = viewController.viewControllers?.first {
            if !force && firstVC !== self {
                return
            }

            if let navBar = viewController.navigationController?.navigationBar {
                navBar.barStyle = statusBarStyleForBackgroundColor(view.backgroundColor!)
                navBar.barTintColor = view.backgroundColor

                if let chromoplast = chromoplast {
                    navBar.tintColor = chromoplast.firstHighlight
                    navBar.titleTextAttributes = [ NSForegroundColorAttributeName: chromoplast.firstHighlight ]
                }
            }
        }
    }

    func updateText(text: String) {
        // TODO:
//        let document = BPParser().parse(text)
//        let converter = BPAttributedStringConverter()
//
//        let defaultFontSize = UIFont.bodyTextFont().pointSize
//        let headerFontSize = UIFont.boldTitleFont().pointSize
//
//        converter.displaySettings.defaultFont = UIFont.bodyTextFont()
//        converter.displaySettings.boldFont = UIFont.latoBoldFontOfSize(defaultFontSize)
//        converter.displaySettings.italicFont = UIFont.latoItalicFontOfSize(defaultFontSize)
//        converter.displaySettings.h1Font = UIFont.boldTitleFont().fontWithSize(headerFontSize * 1.4)
//        converter.displaySettings.h2Font = UIFont.boldTitleFont().fontWithSize(headerFontSize * 1.2)
//        converter.displaySettings.h3Font = UIFont.boldTitleFont()
//
//        metaInformationView.attributedText = converter.convertDocument(document)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let _ = [metaInformationView, imageView, scrollView].map { (view) -> () in
            view.autoresizingMask = .FlexibleWidth
            view.frame.size.width = self.view.frame.size.width
        }

        metaInformationView.backgroundColor = UIColor.clearColor()
        metaInformationView.editable = false
        metaInformationView.textContainerInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)

        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFit

        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.addSubview(imageView)

        let recognizer = UITapGestureRecognizer(target: self, action: "doubleTapped")
        recognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(recognizer)

        view.addSubview(metaInformationView)
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
