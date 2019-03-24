//
//  FavoritePlaceCellData.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/20.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import MapKit

struct FavoritePlaceData: Codable{
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var name: String = "Favorite"
    var adress: String = "adress"
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String, adress: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.adress = adress
    }
}
