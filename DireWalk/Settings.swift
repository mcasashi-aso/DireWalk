//
//  Settings.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/06.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class Settings {
    
    static let shared = Settings()
    private init() {}
    
    @UserDefault(.arrowColor, defaultValue: 0.75)
    var arrowColor: CGFloat
    @UserDefault(.showFar, defaultValue: true)
    var showFar: Bool
    @UserDefault(.isAlwaysDarkAppearance, defaultValue: true)
    var isAlwaysDarkAppearance: Bool
    
}
