//
//  ImageCell.swift
//  Gallery
//
//  Created by Boris Bügling on 16/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

extension CGSize {
    func screenSize() -> CGSize {
        let scale = UIScreen.mainScreen().nativeScale
        return CGSize(width: width * scale, height: height * scale)
    }
}

class ImageCell : UICollectionViewCell {
    let imageView: UIImageView
    let shadowView: UIView

    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        imageView.alpha = 0.9
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 2.0

        shadowView = UIView(frame: frame)
        shadowView.backgroundColor = UIColor.whiteColor()
        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        shadowView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowView.layer.shadowOpacity = 0.5

        super.init(frame: frame)

        addSubview(shadowView)
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        imageView.frame = CGRectInset(bounds, 5.0, 5.0)
        shadowView.frame = CGRectInset(bounds, 5.0, 5.0)

        super.layoutSubviews()
    }
}
