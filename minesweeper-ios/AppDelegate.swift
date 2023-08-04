//
//  AppDelegate.swift
//
//  Created by Ronald Shaker on 4/11/20.
//  Copyright © 2020 Ronald Shaker.
//
//  This file is part of minesweeper-ios.
//
//  minesweeper-ios is free software: you can redistribute it and/or modify
//  it under the terms of the MIT License as published by
//  the Free Software Foundation.
//
//  You should have received a copy of the MIT License along with this program.
//  If not, see <https://opensource.org/licenses/MIT>.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Pause while displaying launch screen, for dramatic effect.
        Thread.sleep(forTimeInterval: 1.0)
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Info.plist allows only portrait orientation during display of LaunchScreen.storyboard.
        // After launch, ease requirement to permit rotation to landscape.
        // Make sure to set allowed device orientations for iphone, ipad seperately under
        // target -> general -> deployment info in xcode project (ipad settings are hidden when both
        // iphone + ipad are checked, so check only one at a time to see the differences)
        // https://stackoverflow.com/questions/30429276/locking-orientation-does-not-work-on-ipad-ios-8-swift-xcode-6-2
        return .allButUpsideDown
    }
}
