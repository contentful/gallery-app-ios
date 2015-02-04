//
//  AppDelegate.swift
//  Gallery
//
//  Created by Boris Bügling on 03/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    class var AccessToken: String { return "ContentfulAccessToken" }
    class var SpaceKey: String { return "ContentfulSpaceKey" }
    class var SpaceChangedNotification: String { return "ContentfulSpaceChangedNotification" }

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        writeKeysToUserDefaults()

        window?.backgroundColor = UIColor.whiteColor()
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)

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

            if let path = components.path {
                if !path.hasPrefix("/space") {
                    return false
                }

                let spaceKey = path.lastPathComponent
                var accessToken: String? = nil

                for parameter in components.query!.componentsSeparatedByString("&") {
                    let parameterComponents = parameter.componentsSeparatedByString("=")

                    if parameterComponents.count != 2 {
                        return false
                    }

                    if parameterComponents[0] == "access_token" {
                        accessToken = parameterComponents[1]
                    }
                }

                if let accessToken = accessToken {
                    NSUserDefaults.standardUserDefaults().setValue(accessToken, forKey: AppDelegate.AccessToken)
                    NSUserDefaults.standardUserDefaults().setValue(spaceKey, forKey: AppDelegate.SpaceKey)

                    NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.SpaceChangedNotification, object: nil, userInfo: [ AppDelegate.SpaceKey: spaceKey, AppDelegate.AccessToken: accessToken ])

                    return true
                }
            }
        }

        return false
    }

    func writeKeysToUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let keys = GalleryKeys()

        if defaults.stringForKey(AppDelegate.SpaceKey) == nil {
            defaults.setValue(keys.gallerySpaceId(), forKey: AppDelegate.SpaceKey)
        }
        
        if defaults.stringForKey(AppDelegate.AccessToken) == nil {
            defaults.setValue(keys.galleryAccessToken(), forKey: AppDelegate.AccessToken)
        }
    }
}
