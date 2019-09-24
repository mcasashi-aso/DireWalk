//
//  VM.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/24.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

protocol VMDelegate: class {
    func didChangePlace()
    func didChangeHeading()
    func didChangeFar()
}

final class VM {
    
    @UserDefault(.place, defaultValue: nil)
    private var place: Place? {
        didSet {
            
        }
    }
    
    var currentLocation: CLLocation? { locationManager.location }
    
    private let locationManager = CurrentLocationManager.shared
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = NotificationCenter.default
    weak var delegate: VMDelegate?
    
    static let shared = VM()
    private init() {
        
    }
    
    // MARK: - Set Place
    func serPlace(_ place: Place) {
        self.place = place
    }
    
    func setPlace(at location: CLLocation) {
        var title, adr: String?
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                (title, adr) = ("new pin", "address")
                return
            }
            if let interest = placemark.areasOfInterest?.first { title = interest }
            else if let name = placemark.name { title = name }
            adr = placemark.address
        }
        wait({ title == nil && adr == nil }) {
            self.place = Place(coordinate: location.coordinate,
                               title: title!, address: adr!)
        }
    }
    
    // MARK: Heading
    var far: Double? {
        didSet { delegate?.didChangeFar() }
    }
    
    var heading: CGFloat { destinationHeadingRadian - userHeadingRadian }
    private var destinationHeadingRadian = CGFloat() {
        didSet { delegate?.didChangeHeading() }
    }
    private var userHeadingRadian = CGFloat() {
        didSet { delegate?.didChangeHeading() }
    }
    
    func updateDestinationHeading() {
        func toRadian(_ angle: CLLocationDegrees) -> CGFloat { CGFloat(angle) * .pi / 180 }
        
        guard let place = self.place,
            let location = self.currentLocation else { return }
        
        let destinationLatitude = toRadian(place.latitude)
        let destinationLongitude = toRadian(place.longitude)
        let userLatitude = toRadian(location.coordinate.latitude)
        let userLongitude = toRadian(location.coordinate.longitude)
        
        let difLongitude = destinationLongitude - userLongitude
        let y = sin(difLongitude)
        let x = cos(userLatitude) * tan(destinationLatitude) - sin(userLatitude) * cos(difLongitude)
        let p = atan2(y, x) * 180 / CGFloat.pi
        destinationHeadingRadian = (p >= 0) ? p : p + 360
    }
}
