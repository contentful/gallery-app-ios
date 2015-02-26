//
//  GalleryListViewController.swift
//  Gallery
//
//  Created by Boris Bügling on 26/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class GalleryCell: UITableViewCell {
    let backgroundImageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let effect = UIBlurEffect(style: .Dark)
        let backgroundView = UIVisualEffectView(effect: effect)
        backgroundView.frame.size = contentView.frame.size
        backgroundView.contentView.addSubview(backgroundImageView)
        contentView.addSubview(backgroundView)

        backgroundImageView.alpha = 0.7
        backgroundImageView.contentMode = .ScaleAspectFill

        textLabel?.backgroundColor = UIColor.clearColor()
        textLabel?.font = UIFont.boldTitleFont()
        textLabel?.numberOfLines = 0
        textLabel?.shadowColor = UIColor.blackColor()
        textLabel?.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textLabel?.textColor = UIColor.whiteColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundImageView.frame.size = contentView.frame.size
        (contentView.subviews.first as? UIView)?.frame.size = contentView.frame.size
    }
}

protocol GalleryListDelegate: class {
    func didSelectAllImages()
    func didSelectGallery(gallery: Photo_Gallery)
}

class GalleryListViewController: UITableViewController {
    var client: CDAClient?
    weak var delegate: GalleryListDelegate?
    var galleries = [Photo_Gallery]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(GalleryCell.self, forCellReuseIdentifier: NSStringFromClass(self.dynamicType))
        tableView.rowHeight = 100.0
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(self.dynamicType), forIndexPath: indexPath) as GalleryCell

        if (indexPath.section == 0) {
            cell.textLabel?.text = "All images"
        } else {
            let gallery = galleries[indexPath.row]

            cell.backgroundImageView.offlineCaching_cda = true
            cell.backgroundImageView.cda_setImageWithPersistedAsset(gallery.coverImage, client: client, size: cell.backgroundImageView.frame.size, placeholderImage: nil)

            cell.textLabel?.text = gallery.title
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate {
            if (indexPath.section == 0) {
                delegate.didSelectAllImages()
            } else {
                delegate.didSelectGallery(galleries[indexPath.row])
            }

            dismissAnimated()
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : galleries.count
    }
}
