//
//  SearchCellModel.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/06.
//  Copyright © 2019 麻生昌志. All rights reserved.
//


import UIKit
import CoreLocation
import HealthKit
import MapKit

protocol SearchCellModelDelegate {
    func didChangeFar()
    func didChangeHeading()
}

final class SearchCellModel: NSObject {
    
    // MARK: - Model
    let place: Place
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2DMake(place.latitude, place.longitude)
    }
    
    let locationManager = CurrentLocationManager.shared
    private let userDefaults = UserDefaults.standard
    var delegate: SearchCellModelDelegate?
    var notificationCenter = NotificationCenter.default
    
    // MARK: - Far
    var far: Double? {
        didSet { delegate?.didChangeFar() }
    }
    var farDescriprion: (String, String) {
        guard let far = far else { return ("", "") }
        switch Int(far) {
        case ..<100:  return (String(Int(far)), "m")
        case ..<1000: return (String((Int(far) / 10 + 1) * 10), "m")
        default:
            let double = Double(Int(far) / 100 + 1) / 10
            if double.truncatingRemainder(dividingBy: 1.0) == 0.0 {
                return (String(Int(double)), "km")
            }else { return (String(double),  "km") }
        }
    }
    
    func updateFar() {
        guard let location = locationManager.location else { return }
        self.far = place.distance(from: location)
    }
    
    // MARK: - Heading
    var heading: CGFloat {
        destinationHeadingRadian - userHeadingRadian
    }
    private var destinationHeadingRadian = CGFloat() {
        didSet { delegate?.didChangeHeading() }
    }
    var userHeadingRadian = CGFloat() {
        didSet { delegate?.didChangeHeading() }
    }
    
    func updateDestinationHeading() {
        func toRadian(_ angle: CLLocationDegrees) -> CGFloat { CGFloat(angle) * .pi / 180 }
        
        let destinationLatitude = toRadian(place.latitude)
        let destinationLongitude = toRadian(place.longitude)
        let userLatitude = toRadian(currentLocation.coordinate.latitude)
        let userLongitude = toRadian(currentLocation.coordinate.longitude)
        
        let difLongitude = destinationLongitude - userLongitude
        let y = sin(difLongitude)
        let x = cos(userLatitude) * tan(destinationLatitude) - sin(userLatitude) * cos(difLongitude)
        let p = atan2(y, x) * 180 / CGFloat.pi
        destinationHeadingRadian = p
    }
    
    // MARK: - Location
    var currentLocation: CLLocation! {
        didSet {
            updateFar()
            updateDestinationHeading()
        }
    }
    
    // MARK: - Initializer
    init(_ place: Place) {
        self.place = place
        self.currentLocation = locationManager.location ?? CLLocation()
        super.init()
        updateFar()
        updateDestinationHeading()
        notificationCenter.addObserver(self, selector: #selector(didUpdateHeading(_:)),
                                       name: .didUpdateUserHeading, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didUpdateLocation(_:)),
                                       name: .didUpdateUserLocation, object: nil)
    }
    
    // MARK: - CurrentLocationManager
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