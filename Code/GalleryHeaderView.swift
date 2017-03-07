//
//  GalleryHeaderView.swift
//  Gallery
//
//  Created by Boris Bügling on 02/03/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class GalleryHeaderView: UICollectionReusableView {
    let backgroundImageView = UIImageView()
    let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let effect = UIBlurEffect(style: .dark)
        let backgroundView = UIVisualEffectView(effect: effect)
        backgroundView.frame.size = frame.size
        backgroundView.contentView.addSubview(backgroundImageView)
        backgroundView.contentView.addSubview(textLabel)
        addSubview(backgroundView)

        backgroundImageView.alpha = 0.5
        backgroundImageView.contentMode = .scaleAspectFill

        textLabel.backgroundColor = .clear
//        textLabel.font = UIFont.boldTitleFont()
        textLabel.numberOfLines = 0
        textLabel.shadowColor = .black
        textLabel.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textLabel.textAlignment = .center
        textLabel.textColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundImageView.frame.size = frame.size
        textLabel.frame.size = frame.size
        subviews.first?.frame.size = frame.size
    }
}

