//
//  NotificationNames.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/29.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static var didChangeFavorites = Notification.Name("didChangeFavorites")
    
    public static var didUpdateUserHeading = Notification.Name("didUpdateHeading")
    public static var didUpdateUserLocation = Notification.Name("didUpdateLocation")
    
    public static var showRequestAccessLocation = Notification.Name("showRequestAccessLocation")
}



// 上手くUserInfoも保存できる形にしたいな
// うーんむずい…無理なのでは…
// あんまNotification多用しないほうがいいし今のままの方がさてはいいのでは…
protocol NotificationDataProtocol {
    var name: String { get }
    var userInfo: [NotificationData.UserInfo<Any>]? { get }
}
struct NotificationData: NotificationDataProtocol {
    let name: String
    let userInfo: [UserInfo<Any>]?
    
    struct UserInfo<T: Any> {
        let key: String
        init(_ key: String) {
            self.key = key
        }
    }
    
    init(_ name: String, userInfo: [UserInfo<Any>]? = nil) {
        (self.name, self.userInfo) = (name, userInfo)
    }
}


extension NotificationCenter {
    func post<N: NotificationDataProtocol>(_ notificationData: N) {
        let name = Notification.Name(notificationData.name)
        let userInfo = notificationData.userInfo?.reduce(into: [:]) { $0[$1.key] = 2 }
        post(name: name, object: nil, userInfo: userInfo)
    }
}


extension NotificationData {
    static let didChangeFavorite = NotificationData("didChangeFavorite")
}


