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
         placeTitle: String?, adress: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.placeTitle = placeTitle
        self.address = adress
    }
    
    init(coordinate: CLLocationCoordinate2D,
         placeTitle: String?, adress: String?) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.placeTitle = placeTitle
        self.address = adress
    }
    
    /// 同じ建物かどうかを返す。
    /// ピンの場所が正確には違っていても、同じ敷地であれば true
    func isEqualPlace(to place: Place) -> Bool {
        self.placeTitle == place.placeTitle &&
            self.address == place.address
    } 
    
    var isFavorite: Bool {
        guard let favorites = UserDefaults.standard.get(.favoritePlaces) else { return false }
        return favorites.contains(self)
    }
    
    func toggleFavorite() {
        let userDefaults = UserDefaults.standard
        if isFavorite {
            guard var favorites = userDefaults.get(.favoritePlaces) else { return }
            favorites.remove(self)
            userDefaults.set(favorites, forKey: .favoritePlaces)
        }else {
            var favorites = userDefaults.get(.favoritePlaces) ?? Set<Place>()
            favorites.insert(self)
            userDefaults.set(favorites, forKey: .favoritePlaces)
        }
        NotificationCenter.default.post(name: .didChangeFavorites, object: nil)
    }
    
    static func ==(lhs: Place, rhs: Place) -> Bool {
        lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
    }
}

extension Place: Codable, UserDefaultConvertible {}
