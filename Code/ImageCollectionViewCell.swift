//
//  ImageCollectionViewCell.swift
//  Gallery
//
//  Created by Boris Bügling on 16/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

extension CGSize {
    func screenSize() -> CGSize {
        let scale = UIScreen.main.nativeScale
        return CGSize(width: width * scale, height: height * scale)
    }
}

class ImageCollectionViewCell: UICollectionViewCell {

    let imageView: UIImageView
    let shadowView: UIView

    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        imageView.alpha = 0.9
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 2.0

        shadowView = UIView(frame: frame)
        shadowView.backgroundColor = .white
        shadowView.layer.shadowColor = UIColor.black.cgColor
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
        imageView.frame = bounds.insetBy(dx: 5.0, dy: 5.0)
        shadowView.frame = bounds.insetBy(dx: 5.0, dy: 5.0)

        super.layoutSubviews()
    }
}
