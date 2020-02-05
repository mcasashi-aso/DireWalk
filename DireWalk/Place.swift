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

struct Place: Hashable, Codable, Identifiable, UserDefaultConvertible, CustomStringConvertible {
    
    var id: String {
        "\(title ?? "")-\(address ?? "")-\(latitude)-\(longitude)"
    }
    
    // MARK: - Base
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    
    var coodinator: CLLocationCoordinate2D {
        .init(latitude: self.latitude, longitude: self.longitude)
    }
    
    var title: String? {
        didSet {
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
        self = Self(latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    title: title,
                    address: address)
    }
    
    // MARK: - Favorite
    var isFavorite: Bool {
        get {
            UserDefaults.standard.get(.favoritePlaces)?.contains(self) ?? false
        }
        set {
            var favorites = UserDefaults.standard.get(.favoritePlaces) ?? []
            switch newValue {
            case true:  favorites.insert(self)
            case false: favorites.remove(self)
            }
            UserDefaults.standard.set(favorites, forKey: .favoritePlaces)
            NotificationCenter.default.post(name: .didChangeFavorites, object: nil)
        }
    }
    
    // MARK: - Functions
    func isSamePlace(to place: Place) -> Bool {
        self.latitude == place.latitude && self.longitude == place.longitude
    }
    
    func distance(from place: Place) -> CLLocationDistance {
        distance(from: CLLocation(latitude: place.latitude, longitude: place.longitude))
    }
    
    func distance(from location: CLLocation) -> CLLocationDistance {
        let loc = CLLocation(latitude: latitude, longitude: longitude)
        return loc.distance(from: location)
    }
    
    // MARK: - Other
    var description: String { "\(title ?? "Title")  -\(address ?? "Address")" }
}
