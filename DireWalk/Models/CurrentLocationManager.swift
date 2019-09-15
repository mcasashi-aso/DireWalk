//
//  CurrentLocationManager.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/12.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import CoreLocation

final class CurrentLocationManager: NSObject {
    
    static let shared = CurrentLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = CLLocationDegrees(floatLiteral: 0.01)
    }

    private let locationManager = CLLocationManager()
    private let notificationCenter = NotificationCenter.default
    var location: CLLocation? {
        locationManager.location
    }
}


extension CurrentLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 許可の管理
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        default:
            notificationCenter.post(name: .showRequestAccessLocation, object: nil, userInfo: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        notificationCenter.post(name: .didUpdateHeading, object: nil,
                                userInfo: ["heading" : newHeading])
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        notificationCenter.post(name: .didUpdateLocation, object: nil,
                                userInfo: ["location" : location])
    }
    
}

