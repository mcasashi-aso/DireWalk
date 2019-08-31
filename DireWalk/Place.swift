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
    var address: String?
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
         placeTitle: String, adress: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.placeTitle = placeTitle
        self.address = adress
        self.isFavorite = isFavoritesContatined(latitude: latitude, longitude: longitude)
    }
    
    init(coordinate: CLLocationCoordinate2D,
         placeTitle: String, adress: String) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.placeTitle = placeTitle
        self.address = adress
        self.isFavorite = isFavoritesContatined(latitude: latitude, longitude: longitude)
    }
    
    /// 同じ建物かどうかを返す。
    /// ピンの場所が正確には違っていても、同じ敷地であれば true
    func isEqualPlace(to place: Place) -> Bool {
        self.placeTitle == place.placeTitle &&
            self.address == place.address
    } 
    
    var isFavorite: Bool {
        didSet {
            switch isFavorite {
            case true:
                var favorites = UserDefaults.standard.get(.favoritePlaces) ?? Set<Place>()
                favorites.insert(self)
                UserDefaults.standard.set(favorites, forKey: .favoritePlaces)
            case false:
                var favorites = UserDefaults.standard.get(.favoritePlaces) ?? Set<Place>()
                favorites.remove(self)
                UserDefaults.standard.set(favorites, forKey: .favoritePlaces)
            }
        }
    }
    
    static func ==(lhs: Place, rhs: Place) -> Bool {
        lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
    }
}

extension Place: Codable, UserDefaultConvertible {}


func isFavoritesContatined(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Bool {
    let favorites = UserDefaults.standard.get(.favoritePlaces) ?? Set<Place>()
    return favorites.contains { (place) -> Bool in
        place.latitude == latitude &&
        place.longitude == longitude
    }
}
