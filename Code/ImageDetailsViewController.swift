//
//  ImageDetailsViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 03/03/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit
import markymark

let metaInformationHeight: CGFloat = 100.0

class ImageDetailsViewController: UIViewController, UIScrollViewDelegate {

    let imageView = UIImageView(frame: .zero)

    let metaInformationView = UITextView(frame: .zero)

    weak var pageViewController: UIPageViewController?

    let scrollView = UIScrollView(frame: .zero)

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillTransition(to size: CGSize,
                            with coordinator: UIViewControllerTransitionCoordinator) {
        computeFrames()
    }

    func computeFrames() {
        // FIXME:

        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown:
            // TODO: leave room for metaInformationHeight
            scrollView.frame.size.height = view.frame.size.height - metaInformationHeight
            metaInformationView.frame.size.height = metaInformationHeight
        default:
            scrollView.frame.size.height = view.frame.size.height
            metaInformationView.frame.origin.y = view.frame.maxY

        }
        metaInformationView.frame.size.height = metaInformationHeight
        metaInformationView.frame.origin.y = scrollView.frame.maxY
    }

    func defaultZoom() {
        guard let image = imageView.image else { return }

        let xZoom = image.size.width / scrollView.frame.size.width
        let yZoom = image.size.height / scrollView.frame.size.height
        scrollView.zoomScale = max(xZoom, yZoom)
        scrollViewDidZoom(scrollView)
    }

    func statusBarStyleForBackgroundColor(color: UIColor?) -> UIBarStyle {
        guard let componentColors = color?.cgColor.components else { return .black }

        var darknessScore = componentColors[0] * 255 * 299
        darknessScore += componentColors[1] * 255 * 587
        darknessScore += componentColors[2] * 255 * 114
        darknessScore /= 1000.0

        return (darknessScore >= 125.0) ? .default : .black
    }

    func updateImage(image: UIImage?) {
        guard image != nil else {
            view.backgroundColor = .white
            imageView.backgroundColor = .white
            return
        }

        defaultZoom()

        DispatchQueue.global(qos: DispatchQoS.default.qosClass).async {
            let size = CGSize(width: 100.0, height: 100.0)

            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            self.imageView.image?.draw(in: CGRect(origin: .zero, size: size))

            DispatchQueue.main.async {
                self.updateNavigationBar(force: false)
            }
        }
    }

    func updateNavigationBar(force: Bool) {
        if let viewController = pageViewController, let firstVC = viewController.viewControllers?.first {
            if !force && firstVC !== self {
                return
            }

            if let navBar = viewController.navigationController?.navigationBar {
                navBar.barStyle = statusBarStyleForBackgroundColor(color: view.backgroundColor)
                navBar.barTintColor = view.backgroundColor
            }
        }
    }

    static func attributedMarkdownText(text: String, font: UIFont) -> NSAttributedString {
        let markyMark = MarkyMark() { $0.setFlavor(ContentfulFlavor()) }
        let markdownItems = markyMark.parseMarkDown(text)
        let styling = DefaultStyling()
        let config = MarkDownToAttributedStringConverterConfiguration(styling: styling)
        // Configure markymark to leverage the Contentful images API when encountering inline SVGs.

        let converter = MarkDownConverter(configuration: config)
        let attributedText = converter.convert(markdownItems)

        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttributes([.font: font], range: range)
        return attributedText
    }

    func updateText(_ text: String) {
        metaInformationView.attributedText = ImageDetailsViewController.attributedMarkdownText(text: text, font: UIFont.systemFont(ofSize: 14.0, weight: .regular))
        metaInformationView.textColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for view in [metaInformationView, imageView, scrollView] {
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

    @objc func doubleTapped() {
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
