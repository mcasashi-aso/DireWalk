//
//  UserDefaultsNames.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/30.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

extension UserDefaultTypedKeys {
    static let place = UserDefaultTypedKey<Place?>("place")
    static let favoritePlaces = UserDefaultTypedKey<Set<Place>>("favoritePlaces")
    
    // MARK: ViewSettings
    static let showFar = UserDefaultTypedKey<Bool>("showFar")
    static let arrowColor = UserDefaultTypedKey<CGFloat>("arrowColorWhite")
    static let isAlwaysDarkAppearance = UserDefaultTypedKey<Bool>("isAlwaysDarkAppearance")
    
    static let date = UserDefaultTypedKey<Date>("date")
    static let usingTimes = UserDefaultTypedKey<Int>("usingTimes")
}
