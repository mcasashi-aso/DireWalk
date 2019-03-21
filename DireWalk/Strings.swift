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
}
