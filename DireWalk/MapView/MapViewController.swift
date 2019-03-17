
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
import GoogleMobileAds

protocol MapViewControllerDelegate {
    func updateMarker(markerName: String)
}

class MapViewController: UIViewController, MKMapViewDelegate, GADBannerViewDelegate {
    
    var delegate: MapViewControllerDelegate?
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    let annotation = MKPointAnnotation()
    
    @IBOutlet weak var bannerView: GADBannerView! {
        didSet{
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
        }
    }
    
    var count = 0.0
    var timer = Timer()
    var pressable = false
    @IBAction func pressMap(_ sender: UILongPressGestureRecognizer) {
        if locationManager.location == nil { return }
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
            
            mapView.removeAnnotation(annotation)
            annotation.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
            addMarker(new: true)
        }
    }
    
    func addMarker(new: Bool) {
        let destination = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let userLocation = locationManager.location
        let far = destination.distance(from: userLocation!)
        var showFar: String!
        if 50 > Int(far) {
            showFar = "\(Int(far))m"
        }else if 500 > Int(far){
            showFar = "\((Int(far) / 10 + 1) * 10)m"
        }else {
            let doubleNum = Double(Int(far) / 100 + 1) / 10
            if doubleNum.truncatingRemainder(dividingBy: 1.0) == 0.0 {
                showFar = "\(Int(doubleNum))km"
            }else {
                showFar = "\(doubleNum)km"
            }
        }
        annotation.subtitle = showFar
        
        var placeName: String!
        CLGeocoder().reverseGeocodeLocation(destination, completionHandler: {placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                placeName = "marker"
                return
            }
            if let interest = placemark.areasOfInterest?[0] {
                placeName = interest
            }else if let name = placemark.name{
                placeName = name
            }
        })
        wait( { return placeName == nil } ) {
            self.annotation.title = placeName
            
            self.delegate?.updateMarker(markerName: placeName)
            self.mapView.addAnnotation(self.annotation)
        }
        
        if new {
            let generater = UIImpactFeedbackGenerator()
            generater.prepare()
            generater.impactOccurred()
        }
        
        userDefaults.set(annotation.coordinate.latitude, forKey: ud.key.annotationLatitude.rawValue)
        userDefaults.set(annotation.coordinate.longitude, forKey: ud.key.annotationLongitude.rawValue)
        userDefaults.set(true, forKey: ud.key.previousAnnotation.rawValue)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
             return nil
        }
        let reuseld = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseld) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseld)
        }else {
            pinView?.annotation = annotation
        }
        pinView?.isSelected = true
        pinView?.animatesWhenAdded = true
        return pinView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        mapView.delegate = self
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        mapView.userTrackingMode = MKUserTrackingMode.follow
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = 0.005
        region.span.longitudeDelta = 0.005
        mapView.setRegion(region, animated: true)
        mapView.mapType = .mutedStandard
        
        setupMapButtons()
        
        if userDefaults.bool(forKey: ud.key.previousAnnotation.rawValue) {
            let latitude: CLLocationDegrees = userDefaults.object(forKey: ud.key.annotationLatitude.rawValue) as! CLLocationDegrees
            let longitude: CLLocationDegrees = userDefaults.object(forKey: ud.key.annotationLongitude.rawValue) as! CLLocationDegrees
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            addMarker(new: false)
        }
        
        setupGesture()
        setupAds()
    }
    
    func setupAds() {
        bannerView.adUnitID = ""
        bannerView.rootViewController = self
        let request = GADRequest()
        
        bannerView.load(request)
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToRecieveAdWithError: \(error.localizedDescription)")
    }
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    // ドラッグの位置記憶用の変数
    var dragPoint: CGPoint?
    func setupGesture() {
        let doubleLongPress = UILongPressGestureRecognizer(target: self, action: #selector(doubleLongPress(_:)))
        
        
        /* ダブルタップ後、即座にLongPress状態に移るように */
        doubleLongPress.minimumPressDuration = 0
        doubleLongPress.numberOfTapsRequired = 1
        
        mapView.addGestureRecognizer(doubleLongPress)
        
        doubleLongPress.delegate = self
        
        /* MKMapViewの機能が実装してあるSubViewを引っ張ってきて、設定してあるDoubleTapGestureRecognizerにdelegateを設定する */
        mapView.subviews[0].gestureRecognizers?.forEach({ (element) in
            if let recognizer = (element as? UITapGestureRecognizer), recognizer.numberOfTapsRequired == 2 {
                element.delegate = self
            }
        })
    }
    
    func setupMapButtons() {
        let userTrackingButtonSpace = CGFloat(3)
        let compassButtonSpace = CGFloat(4)
        let screenWidth = UIScreen.main.bounds.width
        
        let userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.backgroundColor = UIColor.white
        userTrackingButton.frame = CGRect(
            origin: CGPoint(x: (screenWidth - userTrackingButton.bounds.maxX - userTrackingButtonSpace),
                            y: (userTrackingButton.bounds.minY + userTrackingButtonSpace + 50)),
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
                            y: userTrackingButtonSpace + userTrackingButton.bounds.maxX + compassButtonSpace + 50),
            size: compassButton.bounds.size)
        self.view.addSubview(compassButton)
    }
    
    @objc func timeUpdater() {
        count += 0.1
    }
    
    func wait(_ waitContinuation: @escaping (()->Bool), compleation: @escaping (()->Void)) {
        var wait = waitContinuation()
        // 0.01秒周期で待機条件をクリアするまで待ちます。
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            while wait {
                DispatchQueue.main.async {
                    wait = waitContinuation()
                    semaphore.signal()
                }
                semaphore.wait()
                Thread.sleep(forTimeInterval: 0.01)
            }
            // 待機条件をクリアしたので通過後の処理を行います。
            DispatchQueue.main.async {
                compleation()
            }
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
}


extension MapViewController: UIGestureRecognizerDelegate {
    /* このzoomメソッドの実装は適当 */
    func zoom(magnification: Double) {
        var region = mapView.region
        let span = region.span
        region.span = MKCoordinateSpan(latitudeDelta: span.latitudeDelta * magnification, longitudeDelta: span.longitudeDelta * magnification)
        mapView.setRegion(region, animated: false)
    }
    
    /* ダブルタップ → 上下動  で、ズームイン / アウト する (GoogleMap的な挙動) */
    @objc func doubleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let state = recognizer.state
        let location = recognizer.location(in: recognizer.view)
        switch state {
        case .began:
            dragPoint = location
        case .changed:
            /* 上に動いたか下に動いたか判断 */
            let diffY = Double(location.y - dragPoint!.y)
            let magnification = 1 + diffY * 0.01
            self.zoom(magnification: magnification)
            dragPoint = location
            
            mapView.userTrackingMode = MKUserTrackingMode.none
        default:
            break
        }
    }
    
    /* MKMapViewに元から設定されているDoubleTapと、自分で設定したLongPressを同時に機能させる */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
