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
    
    var isFavorite: Bool {
        get {
            guard let favorites = UserDefaults.standard.get(.favoritePlaces) else { return false }
            return favorites.contains(self)
        }
        set {
            let ud = UserDefaults.standard
            switch newValue {
            case true:
                guard var favorites = ud.get(.favoritePlaces) else { return }
                favorites.remove(self)
                ud.set(favorites, forKey: .favoritePlaces)
            case false:
                var favorites = ud.get(.favoritePlaces) ?? Set<Place>()
                favorites.insert(self)
                ud.set(favorites, forKey: .favoritePlaces)
            }
            NotificationCenter.default.post(name: .didChangeFavorites, object: nil)
        }
    }
    
    static func ==(lhs: Place, rhs: Place) -> Bool {
        lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
    }
    
    func distance(from place: Place) -> CLLocationDistance {
        let loca = CLLocation(latitude: latitude, longitude: longitude)
        let location = CLLocation(latitude: place.latitude,
                           longitude: place.longitude)
        return loca.distance(from: location)
    }
    
    func distance(from location: CLLocation) -> CLLocationDistance {
        let loca = CLLocation(latitude: latitude, longitude: longitude)
        return loca.distance(from: location)
    }
}

extension Place: Codable, UserDefaultConvertible {}
