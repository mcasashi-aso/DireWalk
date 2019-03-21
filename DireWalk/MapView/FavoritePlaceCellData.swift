//
//  FavoritePlaceCellData.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/20.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import MapKit

class FavoritePlaceData: NSObject, NSCoding {
    
    func encode(with aCoder: NSCoder) {
        if let latitude = latitude { aCoder.encode(latitude, forKey: "latitude") }
        if let longitude = longitude { aCoder.encode(longitude, forKey: "longitude") }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.latitude = (aDecoder.decodeObject(forKey: "latitude")) as? CLLocationDegrees ?? CLLocationDegrees(exactly: 0.0)
        self.longitude = (aDecoder.decodeObject(forKey: "longitude")) as? CLLocationDegrees ?? CLLocationDegrees(exactly: 0.0)
    }
    
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
