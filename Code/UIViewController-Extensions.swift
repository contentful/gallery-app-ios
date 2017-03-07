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
        let infoButton = UIButton(type: .infoLight) as UIButton
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }

    func infoTapped() {
        // TODO:
        let aboutUsViewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: aboutUsViewController)

        // TODO: this should be moved inside view controller
        navigationController.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target:navigationController, action: #selector(dismissAnimated))
        present(navigationController, animated: true, completion: nil)
    }

    func dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }
}
