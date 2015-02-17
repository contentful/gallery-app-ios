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
    let titleLabel: UILabel

    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        imageView.alpha = 0.9
        imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        imageView.contentMode = .ScaleAspectFit

        titleLabel = UILabel(frame: frame)
        titleLabel.autoresizingMask = .FlexibleWidth
        titleLabel.font = UIFont.boldTitleFont()
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .Center

        super.init(frame: frame)

        self.addSubview(imageView)
        self.addSubview(titleLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        imageView.frame = self.bounds
        titleLabel.frame = CGRectInset(self.bounds, 30.0, 30.0)

        super.layoutSubviews()
    }
}
