//
//  ImageCell.swift
//  Gallery
//
//  Created by Boris Bügling on 16/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

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

        imageView.frame = self.bounds
        self.addSubview(imageView)

        titleLabel.frame = CGRectInset(self.bounds, 30.0, 30.0)
        self.addSubview(titleLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
