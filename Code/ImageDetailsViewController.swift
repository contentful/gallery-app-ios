//
//  ImageDetailsViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 03/03/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit
import SOZOChromoplast

let metaInformationHeight = CGFloat(100.0)

class ImageDetailsViewController: UIViewController, UIScrollViewDelegate {
    var chromoplast: SOZOChromoplast?
    let imageView = UIImageView(frame: .zero)
    let metaInformationView = UITextView(frame: .zero)
    weak var pageViewController: UIPageViewController?
    let scrollView = UIScrollView(frame: .zero)
    // FIXME:
//
//    deinit {
//        kvoController?.unobserve(imageView)
//    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        // FIXME:
//        kvoController = FBKVOController(observer: self)
//        kvoController?.observe(imageView, keyPath: "image", options: .New, context: nil)
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

    // FIXME:
//    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
//        super.didRotate(from: fromInterfaceOrientation)
//
//        UIView.animate(withDuration: 0.1) {
//            self.computeFrames()
//        }
//    }

    // FIXME:
//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
//        updateImage(image: imageView.image)
//    }

    func statusBarStyleForBackgroundColor(color: UIColor) -> UIBarStyle {
        let componentColors = color.cgColor.components!

        var darknessScore = componentColors[0] * 255 * 299
        darknessScore += componentColors[1] * 255 * 587
        darknessScore += componentColors[2] * 255 * 114
        darknessScore /= 1000.0

        return (darknessScore >= 125.0) ? .default : .black
    }

    func updateImage(image: UIImage?) {
        if image == nil {
            view.backgroundColor = .white
            imageView.backgroundColor = .white
            return
        }

        defaultZoom()

        DispatchQueue.global(qos: DispatchQoS.default.qosClass).async {
            let size = CGSize(width: 100.0, height: 100.0)

            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            self.imageView.image?.draw(in: CGRect(origin: .zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            self.chromoplast = SOZOChromoplast(image: scaledImage)

            DispatchQueue.main.async {
                self.view.backgroundColor = self.chromoplast!.dominantColor
                self.imageView.backgroundColor = self.chromoplast!.dominantColor

                let mutableText = self.metaInformationView.attributedText.mutableCopy() as! NSMutableAttributedString

                guard let firstLine = mutableText.string.range(of: "\n") else { return }


                let range = NSMakeRange(0, mutableText.string.distance(from: mutableText.string.startIndex, to: firstLine.lowerBound))

                mutableText.addAttribute(NSForegroundColorAttributeName, value: self.chromoplast!.firstHighlight!, range: range)
                mutableText.addAttribute(NSForegroundColorAttributeName, value: self.chromoplast!.secondHighlight!, range: NSMakeRange(range.length, mutableText.string.distance(from: firstLine.upperBound, to: mutableText.string.endIndex)))

                self.metaInformationView.attributedText = mutableText

                self.updateNavigationBar(force: false)
            }
        }
    }

    func updateNavigationBar(force: Bool) {
        if let viewController = self.pageViewController, let firstVC = viewController.viewControllers?.first {
            if !force && firstVC !== self {
                return
            }

            if let navBar = viewController.navigationController?.navigationBar {
                navBar.barStyle = statusBarStyleForBackgroundColor(color: view.backgroundColor!)
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
            view.autoresizingMask = .flexibleWidth
            view.frame.size.width = self.view.frame.size.width
        }

        metaInformationView.backgroundColor = .clear
        metaInformationView.isEditable = false
        metaInformationView.textContainerInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)

        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit

        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.addSubview(imageView)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        recognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(recognizer)

        view.addSubview(metaInformationView)
        view.addSubview(scrollView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        computeFrames()
        defaultZoom()
        updateNavigationBar(force: true)
    }

    // MARK: Actions

    func doubleTapped() {
        UIView.animate(withDuration: 0.1) {
            self.defaultZoom()
        }
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let innerFrame = imageView.frame
        let scrollerBounds = scrollView.bounds

        if (innerFrame.size.width < scrollerBounds.size.width) || (innerFrame.size.height < scrollerBounds.size.height) {
            scrollView.contentOffset = CGPoint(x: imageView.center.x - (scrollerBounds.size.width / 2), y: imageView.center.y - (scrollerBounds.size.height / 2))
        }

        var insets = UIEdgeInsets.zero

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
