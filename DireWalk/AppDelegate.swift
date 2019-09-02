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
        // 前のバージョンからかなり修正が加わってるので、一度リセットする
//        userDefaults.register(defaults: ["first" : true])
//        if userDefaults.bool(forKey: "first") {
            let domain = Bundle.main.bundleIdentifier
            userDefaults.removePersistentDomain(forName: domain!)
//            userDefaults.set(false, forKey: "first")
//        }
        
        // 前回起動から3時間以上経っていた場合、データを消す
        let now = Date()
        let hoge = Date(timeInterval: -60*60*3+1, since: now)
        let previous = userDefaults.get(.date) ?? hoge
        if Date(timeInterval: -60*60*3, since: now) > previous {
            userDefaults.set(nil, forKey: .place)
        }
        
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

