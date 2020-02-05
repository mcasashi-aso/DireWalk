//
//  CurrentLocationManager.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/12.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import CoreLocation
import Foundation

final class LocationController: NSObject {
    
    static let shared = LocationController()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = CLLocationDegrees(floatLiteral: 0.01)
    }

    private let locationManager = CLLocationManager()
    private let notificationCenter = NotificationCenter.default
    var location: CLLocation? { locationManager.location }
    var heading:  CLHeading?  { locationManager.heading  }
}


extension LocationController: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        // 許可の管理
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        default:
            notificationCenter.post(name: .showRequestAccessLocation, object: nil, userInfo: nil)
        }
    }
    
    func locationManager(_ _: CLLocationManager, didUpdateHeading _: CLHeading) {
        notificationCenter.post(name: .didUpdateUserHeading, object: nil)
    }
    
    func locationManager(_ _: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        notificationCenter.post(name: .didUpdateUserLocation, object: nil)
    }
    
}

