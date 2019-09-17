//
//  DirectionModel.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol ModelDelegate {
    func didChangePlace()
    func didChangeFar()
    func didChangeHeading()
}

final class Model: NSObject {
    
    // MARK: - Model
    @UserDefault(.place, defaultValue: nil)
    var place: Place? {
        didSet {
            updateFar()
            delegate?.didChangePlace()
        }
    }
    var coordinate: CLLocationCoordinate2D? {
        guard let p = place else { return nil }
        return CLLocationCoordinate2DMake(p.latitude, p.longitude)
    }
    
    var far: Double? {
        didSet { delegate?.didChangeFar() }
    }
    
    var heading: CGFloat { destinationHeadingRadian - userHeadingRadian }
    private var destinationHeadingRadian = CGFloat() {
        didSet { delegate?.didChangeHeading() }
    }
    var userHeadingRadian = CGFloat() {
        didSet { delegate?.didChangeHeading() }
    }
    
    var currentLocation = CLLocation() {
        didSet {
            updateFar()
            updateDestinationHeading()
        }
    }
    
    // MARK: - Singlton
    static let shared = Model()
    private override init() {
        super.init()
        notificationCenter.addObserver(self, selector: #selector(didUpdateLocation(_:)), name: .didUpdateUserLocation, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didUpdateHeading(_:)), name: .didUpdateUserHeading, object: nil)
    }
    
    let locationManager = CurrentLocationManager.shared
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = NotificationCenter.default
    var delegate: ModelDelegate?

    // MARK: - Marker
    func setPlace(_ location: CLLocation) {
        var title, adr: String?
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                title = "new pin"
                adr = "adress"
                return
            }
            if let interest = placemark.areasOfInterest?.first { title = interest }
            else if let name = placemark.name { title = name }
            adr = placemark.address
        }
        wait({ title == nil && adr == nil }) {
            self.place = Place(coordinate: location.coordinate,
                               title: title!, adress: adr!)
        }
    }

    // MARK: - Heading
    func updateDestinationHeading() {
        func toRadian(_ angle: CLLocationDegrees) -> CGFloat { CGFloat(angle) * .pi / 180 }
        
        guard let place = self.place else { return }
        
        let destinationLatitude = toRadian(place.latitude)
        let destinationLongitude = toRadian(place.longitude)
        let userLatitude = toRadian(currentLocation.coordinate.latitude)
        let userLongitude = toRadian(currentLocation.coordinate.longitude)
        
        let difLongitude = destinationLongitude - userLongitude
        let y = sin(difLongitude)
        let x = cos(userLatitude) * tan(destinationLatitude) - sin(userLatitude) * cos(difLongitude)
        let p = atan2(y, x) * 180 / CGFloat.pi
        destinationHeadingRadian = (p >= 0) ? p : p + 360
    }

    // MARK: - Far
    func updateFar() {
        guard let place = place else { return }
        self.far = place.distance(from: currentLocation)
    }

    // MARK: - CurrentLocationManagerDelegate
    @objc func didUpdateHeading(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String : Any],
            let heading = userInfo["heading"] as? CLHeading else { return }
        userHeadingRadian = CGFloat(heading.magneticHeading)
    }
    
    @objc func didUpdateLocation(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String : Any],
            let location = userInfo["location"] as? CLLocation else { return }
        currentLocation = location
    }
}
