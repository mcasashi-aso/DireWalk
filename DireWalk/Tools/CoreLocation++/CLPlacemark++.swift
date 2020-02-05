//
//  CLPlacemark++.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/12/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import CoreLocation

extension CLPlacemark {
    var address: String {
        let components = [administrativeArea, locality, thoroughfare, subThoroughfare]
        return components.compactMap { $0 }.joined(separator: "")
    }
}
