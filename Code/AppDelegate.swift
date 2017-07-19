//
//  AppDelegate.swift
//  Gallery
//
//  Created by Boris Bügling on 03/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit
import Keys

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        window?.backgroundColor = .white
        return true
    }
}
