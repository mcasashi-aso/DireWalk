//
//  Strings.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/01.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import UIKit

struct ud {
    enum key: String{
        case annotationLatitude
        case annotationLongitude
        case destinationName
        case previousAnnotation
        case directoinButtonHeading
        case usingTimes
        case showFar
        case favoritePlaces
    }
}

extension Notification.Name {
    public static let addFavorite = Notification.Name("addFavorite")
    public static let reloadFavorite = Notification.Name("reloadFavorite")
    public static let fitFavolitCollectionView = NSNotification.Name("fitFavolitCollectionView")
    public static let endEditing = Notification.Name("endEditing")
}

extension UIColor {
    public static let myBlue = #colorLiteral(red: 0.04705882353, green: 0.3921568627, blue: 1, alpha: 1)
}
