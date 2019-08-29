//
//  Place.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

struct Place: Hashable, Equatable {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    
    var placeTitle: String?
    var adress: String?
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
         placeTitle: String, adress: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.placeTitle = placeTitle
        self.adress = adress
    }
    
    init(coordinate: CLLocationCoordinate2D, placeTitle: String, adress: String) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.placeTitle = placeTitle
        self.adress = adress
    }
    
    /// 同じ建物かどうかを返す。
    /// ピンの場所が正確には違っていても、同じ敷地であれば true
    func isEqualPlace(to place: Place) -> Bool {
        self.placeTitle == place.placeTitle &&
            self.adress == place.adress
    }
}

extension Place: Codable {
    
}

extension Place: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? Place else { return nil }
        self = value
    }
    func object() -> Any? { self }
}
