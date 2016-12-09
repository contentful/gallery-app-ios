//
//  UIViewController-Extensions.swift
//  Blog
//
//  Created by Boris Bügling on 28/01/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

extension UIViewController {
    func addInfoButton() {
        let infoButton = UIButton(type: .InfoLight) as UIButton
        infoButton.addTarget(self, action: #selector(infoTapped), forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }

    func infoTapped() {
        // TODO:
        let aboutUsViewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: aboutUsViewController)

        // TODO: this should be moved inside view controller
        navigationController.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target:navigationController, action: #selector(dismissAnimated))
        presentViewController(navigationController, animated: true, completion: nil)
    }

    func dismissAnimated() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
