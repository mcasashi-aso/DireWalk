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

struct Place: Hashable, Equatable, Codable, UserDefaultConvertible, CustomStringConvertible {
    
    // MARK: - Base
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    
    var coodinator: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    var title: String? {
        didSet {
            guard title != oldValue else { return }
            var favorites = UserDefaults.standard.get(.favoritePlaces) ?? []
            if let old = favorites.first(where: { $0.isSamePlace(to: self) }) {
                favorites.remove(old)
                favorites.insert(self)
                UserDefaults.standard.set(favorites, forKey: .favoritePlaces)
                NotificationCenter.default.post(name: .didChangeFavorites, object: nil)
            }
        }
    }
    var address: String?
    
    // MARK: - Initializer
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
         title: String?, address: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.address = address
        let favorites = UserDefaults.standard.get(.favoritePlaces) ?? []
        if let favorite = favorites.first(where: { $0.isSamePlace(to: self) }) {
            self.title = favorite.title
        }
    }
    
    init(coordinate: CLLocationCoordinate2D,
         title: String?, address: String?) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.title = title
        self.address = address
    }
    
    // MARK: - Favorite
    var isFavorite: Bool {
        get {
            guard let favorites = UserDefaults.standard.get(.favoritePlaces) else { return false }
            return favorites.contains(self)
        }
        set {
            let ud = UserDefaults.standard
            switch newValue {
            case true:
                var favorites = ud.get(.favoritePlaces) ?? Set<Place>()
                favorites.insert(self)
                ud.set(favorites, forKey: .favoritePlaces)
            case false:
                guard var favorites = ud.get(.favoritePlaces) else { return }
                favorites.remove(self)
                ud.set(favorites, forKey: .favoritePlaces)
            }
            NotificationCenter.default.post(name: .didChangeFavorites, object: nil)
        }
    }
    
    // MARK: - Functions
    func isSamePlace(to place: Place) -> Bool {
        self.latitude == place.latitude &&
            self.longitude == place.longitude
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
    
    // MARK: - Other
    var description: String { "\(title ?? "Title")  -\(address ?? "Address")" }
}
