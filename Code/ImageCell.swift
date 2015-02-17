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
    let dateLabel: UILabel
    let imageView: UIImageView
    let titleLabel: UILabel

    override init(frame: CGRect) {
        dateLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 40.0))
        dateLabel.font = UIFont.tabTitleFont()
        dateLabel.textAlignment = .Right

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
        self.addSubview(dateLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        dateLabel.frame.origin.x = frame.size.width - dateLabel.frame.size.width - 10.0
        dateLabel.frame.origin.y = frame.size.height - dateLabel.frame.size.height

        imageView.frame = self.bounds
        titleLabel.frame = CGRectInset(self.bounds, 30.0, 30.0)

        super.layoutSubviews()
    }
}
