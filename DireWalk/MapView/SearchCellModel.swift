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
    
    let place: Place
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2DMake(place.latitude, place.longitude)
    }
    
    var far: Double? { didSet { delegate?.didChangeFar() } }
    var farDescriprion: (String, String) {
        guard let far = far else { return ("Error", " ") }
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
    
    var heading: CGFloat { destinationHeadingRadian - userHeadingRadian }
    private var destinationHeadingRadian = CGFloat() {
        didSet { delegate?.didChangeHeading() }
    }
    var userHeadingRadian = CGFloat() {
        didSet { delegate?.didChangeHeading() }
    }
    
    var currentLocation = CLLocation() {
        didSet { updateFar() }
    }
    
    init(_ place: Place) {
        self.place = place
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = CLLocationDegrees(floatLiteral: 0.1)
    }
    
    let locationManager = CLLocationManager()
    private let userDefaults = UserDefaults.standard
    private let healthStore = HKHealthStore()
    var delegate: ModelDelegate?
}

// MARK: Heading
extension SearchCellModel {
    func updateDestinationHeading() {
        func toRadian(_ angle: CLLocationDegrees) -> CGFloat {
            return CGFloat(angle) * .pi / 180
        }
        
        let destinationLatitude = toRadian(place.latitude)
        let destinationLongitude = toRadian(place.longitude)
        let userLatitude = toRadian((locationManager.location?.coordinate.latitude)!)
        let userLongitude = toRadian((locationManager.location?.coordinate.longitude)!)
        
        let difLongitude = destinationLongitude - userLongitude
        let y = sin(difLongitude)
        let x = cos(userLatitude) * tan(destinationLatitude) - sin(userLatitude) * cos(difLongitude)
        let p = atan2(y, x) * 180 / CGFloat.pi
        destinationHeadingRadian = (p >= 0) ? p : p + 360
    }
}

 // MARK: Far
extension SearchCellModel {
    func updateFar() {
        let destination = CLLocation(latitude: place.latitude, longitude: place.longitude)
        self.far = destination.distance(from: currentLocation)
    }
}

// MARK: CLLocationManagerDelegate
extension SearchCellModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userHeadingRadian = CGFloat(newHeading.magneticHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        UserDefaults.standard.set(Date(), forKey: .date)
        guard let location = manager.location else { return }
        self.currentLocation = location
        updateFar()
        updateDestinationHeading()
    }
}
