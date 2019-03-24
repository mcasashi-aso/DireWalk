//
//  AppDelegate.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let userDefaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /* 初期化用 */
//        let domain = Bundle.main.bundleIdentifier
//        userDefaults.removePersistentDomain(forName: domain!)
//        userDefaults.synchronize()
        
        let now = Date()
        let measureOfNil = Date(timeInterval: -60*60*3+1, since: now)
        userDefaults.register(defaults: ["date" : measureOfNil])
        let previous: Date = userDefaults.object(forKey: "date") as! Date
        userDefaults.register(defaults: [udKey.previousAnnotation.rawValue : false])
        if Date(timeInterval: -60*60*3, since: now) > previous{
            userDefaults.set(false, forKey: udKey.previousAnnotation.rawValue)
        }
        userDefaults.set(now, forKey: "date")
        
        userDefaults.register(defaults: [udKey.showFar.rawValue : false])
        userDefaults.set([Int](), forKey: udKey.deletedFavoritePlaces.rawValue)
        userDefaults.set(false, forKey: udKey.favoritePlaceIsEditing.rawValue)
        
        FirebaseApp.configure()

        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        sleep(1)
        return
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

