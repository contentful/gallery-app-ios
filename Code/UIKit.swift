//
//  UIKit.swift
//  Blog
//
//  Created by Boris Bügling on 28/01/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit
import ContentfulDialogs

extension UIViewController {
    func addInfoButton() {
        let infoButton = UIButton(type: .infoLight) as UIButton
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }

    @objc func infoTapped() {
        let aboutUsViewController = AboutUsViewController()
        let navigationController = UINavigationController(rootViewController: aboutUsViewController)

        navigationController.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target:navigationController, action: #selector(dismissAnimated))
        present(navigationController, animated: true, completion: nil)
    }

    @objc func dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }
}
