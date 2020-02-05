//
//  ModelWithCombine.swift
//  DireWalk for watchOS Extension
//
//  Created by Masashi Aso on 2019/12/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Combine
import CoreLocation
import Foundation

final class Model: NSObject, ObservableObject, Identifiable {
    
    @UserDefault(.place, defaultValue: nil)
    private(set) var place: Place? {
        willSet { objectWillChange.send() }
    }
    
    @Published private(set) var distance: Double?
    
    @Published private(set) var heading: Double?
    private var destinationHeadingRadian: Double? { didSet { updateHeading() } }
    private var userHeadingRadian: Double? { didSet { updateHeading() } }
    private func updateHeading() {
        heading = destinationHeadingRadian.flatMap {
            x in userHeadingRadian.map { y in x - y }
        }
    }
    
    var currentLocation: CLLocation? {
        locationController.location
    }
    
    override init() {
        super.init()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(didUpdateLocation(_:)),
                       name: .didUpdateUserLocation, object: nil)
        nc.addObserver(self, selector: #selector(didUpdateHeading(_:)),
                       name: .didUpdateUserHeading, object: nil)
    }
    
    convenience init(place: Place) {
        self.init()
        self.place = place
        updateDistance()
        updateHeading()
    }
    
    var id: String { place?.id ?? "non place model" }
    
    private let locationController = LocationController.shared
    
    func setPlace(at location: CLLocation) {
        // Place Holderを作成
        self.place = Place(coordinate: location.coordinate, title: "Fetching...", address: "Fetching...")
        
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            let title = placemarks?.first
                .map { $0.areasOfInterest?.first ?? $0.name ?? $0.address } ?? "new pin"
            let address = placemarks?.first?.address ?? "address"
            self.place = Place(coordinate: location.coordinate, title: title, address: address)
        }
    }
    
    func updateDistance() {
        guard let current = currentLocation else { return }
        self.distance = place?.distance(from: current)
    }
    
    // MARK: - LocationControllerNotification
    @objc func didUpdateHeading(_ notification: Notification) {
        guard let heading = locationController.heading else { return }
        userHeadingRadian = Double(heading.magneticHeading)
    }
    
    @objc func didUpdateLocation(_ notification: Notification) {
        guard let place = self.place, let current = currentLocation else { return }
        
        func toRadian(_ angle: CLLocationDegrees) -> Double { Double(angle) * .pi / 180 }
        
        let userLatitude = toRadian(current.coordinate.latitude)
        let userLongitude = toRadian(current.coordinate.longitude)
        let difLongitude = toRadian(place.longitude) - userLongitude
        let y = sin(difLongitude)
        let x = cos(userLatitude) * tan(toRadian(place.latitude)) - sin(userLatitude) * cos(difLongitude)
        let p = atan2(y, x) * 180 / .pi
        destinationHeadingRadian = (p >= 0) ? p : p + 360
    }
}

