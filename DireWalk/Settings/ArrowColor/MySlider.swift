//
//  MySlider.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class TappableSlider: UISlider {
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = super.trackRect(forBounds: bounds)
        bounds.size.height = 12
        return bounds
    }
    
}
