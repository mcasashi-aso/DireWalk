//
//  DirectionModel.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import MapKit

protocol ModelDelegate {
    func showRequestAccessLocation()
    func addHeadingView(to annotationView: MKAnnotationView)
    
    func didChangePlace()
    func didChangeFar()
    func didChangeHeading()
}

class Model: NSObject {
    
    @UserDefault(.place, defaultValue: nil)
    var place: Place? {
        didSet {
            updateFar()
            delegate?.didChangePlace()
        }
    }
    var coordinate: CLLocationCoordinate2D {
        guard let p = place else { return CLLocationCoordinate2D()  }
        return CLLocationCoordinate2DMake(p.latitude, p.longitude)
    }
    
    var far: Double? {
        didSet { delegate?.didChangeFar() }
    }
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
    
    static let shared = Model()
    private override init() {
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

// MARK: Marker
extension Model {
    func setPlace(_ location: CLLocation) {
        var title, adr: String?
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                title = "new pin"
                adr = "adress"
                return
            }
            if let interest = placemark.areasOfInterest?.first { title = interest }
            else if let name = placemark.name{ title = name }
            if let adress = placemark.name { adr = adress }
            else { adr = "\(location.coordinate.latitude), \(location.coordinate.longitude)" }
        }
        wait({ title == nil && adr == nil }) {
            print("here")
            self.place = Place(coordinate: location.coordinate,
                          placeTitle: title!, adress: adr!)
            print("s")
        }
    }
}

// MARK: Heading
extension Model {
    func updateDestinationHeading() {
        func toRadian(_ angle: CLLocationDegrees) -> CGFloat {
            return CGFloat(angle) * .pi / 180
        }
        
        guard let place = self.place else { return }
        
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
extension Model {
    func updateFar() {
        guard let lat = place?.latitude,
            let lon = place?.longitude else { return }
        let destination = CLLocation(latitude: lat, longitude: lon)
        self.far = destination.distance(from: currentLocation)
    }
}

// MARK: CLLocationManagerDelegate
extension Model: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 許可の管理
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        default: delegate?.showRequestAccessLocation()
        }
        
        if status == .authorizedWhenInUse || status == .authorizedWhenInUse {
            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
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


// MKMapViewDelegate
extension Model: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let reuseld = "pin"
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseld) as? MKMarkerAnnotationView ??
            MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseld)
        pinView.annotation = annotation
        pinView.isSelected = true
        pinView.animatesWhenAdded = true
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if views.last?.annotation is MKUserLocation {
            delegate?.addHeadingView(to: views.last!)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.didChangeHeading()
    }
}
