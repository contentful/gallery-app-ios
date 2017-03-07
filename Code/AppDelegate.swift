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


    class var AccessToken: String { return "ContentfulAccessToken" }
    class var SpaceKey: String { return "ContentfulSpaceKey" }
    class var SpaceChangedNotification: String { return "ContentfulSpaceChangedNotification" }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        writeKeysToUserDefaults()

        window?.backgroundColor = .white
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        if let components = components {
            if components.scheme != "contentful-gallery" {
                return false
            }

            if components.host != "open" {
                return false
            }

            if components.query == nil {
                return false
            }

            let path = components.path
            if !path.hasPrefix("/space") {
                return false
            }

            let spaceKey = (path as NSString).lastPathComponent
            var accessToken: String? = nil

            for parameter in components.query!.components(separatedBy: "&") {
                let parameterComponents = parameter.components(separatedBy: "=")

                if parameterComponents.count != 2 {
                    return false
                }

                if parameterComponents[0] == "access_token" {
                    accessToken = parameterComponents[1]
                }
            }

            if let accessToken = accessToken {
                UserDefaults.standard.setValue(accessToken, forKey: AppDelegate.AccessToken)
                UserDefaults.standard.setValue(spaceKey, forKey: AppDelegate.SpaceKey)

                NotificationCenter.default.post(name: Notification.Name(rawValue: AppDelegate.SpaceChangedNotification), object: nil, userInfo: [ AppDelegate.SpaceKey: spaceKey, AppDelegate.AccessToken: accessToken ])

                return true
            }

        }

        return false
    }

    func writeKeysToUserDefaults() {
        let defaults = UserDefaults.standard
        let keys = GalleryKeys()

        if defaults.string(forKey: AppDelegate.SpaceKey) == nil {
            defaults.set(keys.gallerySpaceId()!, forKey: AppDelegate.SpaceKey)
        }
        
        if defaults.string(forKey: AppDelegate.AccessToken) == nil {
            defaults.set(keys.galleryAccessToken()!, forKey: AppDelegate.AccessToken)
        }
        defaults.synchronize()
    }
}
