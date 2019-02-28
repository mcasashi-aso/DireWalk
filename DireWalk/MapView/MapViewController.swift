
//
//  MapViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var myLocationManager: CLLocationManager!
    
    let annotation = MKPointAnnotation()
    
    var count = 0.0
    var timer = Timer()
    var pressable = true

    @IBAction func pressMap(_ sender: UILongPressGestureRecognizer) {
        let location: CGPoint = sender.location(in: mapView)
        if sender.state == UIGestureRecognizer.State.began {
            pressable = true
            self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                                              target: self,
                                              selector: #selector(self.timeUpdater),
                                              userInfo: nil,
                                              repeats: true)
        }
        if pressable == false { return }
        if count >= 0.5 {
            pressable = false
            timer.invalidate()
            let mapPoint: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
            
            annotation.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
            annotation.title = "テスト"
            annotation.subtitle = "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
            
            mapView.addAnnotation(annotation)
            
            let generater = UIImpactFeedbackGenerator()
            generater.prepare()
            generater.impactOccurred()
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
             return nil
        }
        
        let reuseld = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseld) as? MKMarkerAnnotationView
        pinView?.animatesWhenAdded = true
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseld)
        }else {
            pinView?.annotation = annotation
        }
        pinView?.isSelected = true
        return pinView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        myLocationManager = CLLocationManager()
        myLocationManager.startUpdatingLocation()
        myLocationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        mapView.userTrackingMode = MKUserTrackingMode.follow
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = 0.005
        region.span.longitudeDelta = 0.005
        mapView.setRegion(region, animated: true)
        
        let userTrackingButtonSpace = CGFloat(3)
        let compassButtonSpace = CGFloat(4)
        let screenWidth = UIScreen.main.bounds.width
        
        let userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.backgroundColor = UIColor.white
        userTrackingButton.frame = CGRect(
            origin: CGPoint(x: (screenWidth - userTrackingButton.bounds.maxX - userTrackingButtonSpace),
                            y: (userTrackingButton.bounds.minY + userTrackingButtonSpace)),
            size: userTrackingButton.bounds.size)
        userTrackingButton.layer.cornerRadius = userTrackingButton.bounds.height / 6
        userTrackingButton.layer.masksToBounds = true
        userTrackingButton.layer.shadowColor = UIColor.black.cgColor
        userTrackingButton.layer.shadowOpacity = 0.5
        userTrackingButton.layer.shadowRadius = 4
        
        self.view.addSubview(userTrackingButton)
        
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .adaptive
        compassButton.frame = CGRect(
            origin: CGPoint(x: screenWidth - compassButton.bounds.width - compassButtonSpace,
                            y: userTrackingButtonSpace + userTrackingButton.bounds.maxX + compassButtonSpace),
            size: compassButton.bounds.size)
        self.view.addSubview(compassButton)
    }
    
    
    
    @objc func timeUpdater() {
        count += 0.1
    }
    
}
