
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
    func changeMapTabButtonImage(isShowingPlaces: Bool)
}

class MapViewController: UIViewController, MKMapViewDelegate, GADBannerViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, FavoritePlacesViewControllerDelegate {
    
    func showPlace() {
        
    }
    
    var favoriteName = ""
    var favoriteAdress = ""
    @objc func addFavorite() {
        if annotation.coordinate.latitude == 0 || annotation.coordinate.longitude == 0 { return }
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        let favoritePlace = FavoritePlaceData(latitude: latitude,
                                              longitude: longitude,
                                              name: favoriteName,
                                              adress: favoriteAdress)
        print(favoritePlace.name)
        print(favoritePlace.adress)
        print(favoritePlace.longitude)
        var places = [FavoritePlaceData]()
        if let udPlaces = userDefaults.object(forKey: ud.key.favoritePlaces.rawValue) as? Data{
            places = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(udPlaces) as! [FavoritePlaceData]
        }
        places.append(favoritePlace)
        let placesOfData = try? NSKeyedArchiver.archivedData(withRootObject: places, requiringSecureCoding: false)
        userDefaults.set(placesOfData, forKey: ud.key.favoritePlaces.rawValue)
        NotificationCenter.default.post(name: .reloadFavorite, object: nil)
    }
    
    
    public var isShowingPlaces = false
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            scrollView.delegate = self
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            isShowingPlaces = true
            showFavoritePlaces()
        }else {
            isShowingPlaces = false
            showFavoritePlaces()
        }
    }
    
    func showFavoritePlaces() {
        delegate?.changeMapTabButtonImage(isShowingPlaces: isShowingPlaces)
        if isShowingPlaces {
            scrollView.isUserInteractionEnabled = true
        }else {
            scrollView.isUserInteractionEnabled = false
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
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
    @objc func timeUpdater() {
        count += 0.1
    }
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
                self.favoriteName = interest
            }else if let name = placemark.name{
                placeName = name
                self.favoriteName = "Favorite"
            }
            if let adress = placemark.name {
                self.favoriteAdress = adress
            }else {
                self.favoriteAdress = "adress"
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
    
    
    var headingImageView = UIImageView(image: UIImage(named: "UserHeading"))
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if views.last?.annotation is MKUserLocation {
            addHeadingView(toAnnotationView: views.last!)
        }
    }
    
    func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
        headingImageView.frame = CGRect(x: (annotationView.frame.size.width - 40)/2,
                                        y: (annotationView.frame.size.height - 40)/2,
                                        width: 40,
                                        height: 40)
        annotationView.insertSubview(headingImageView, at: 0)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        let heading = newHeading.trueHeading > 0 ?newHeading.trueHeading : newHeading.magneticHeading
        updateHeadingRotation(heading: heading)
    }

    func updateHeadingRotation(heading: CLLocationDirection) {
        let rotation = CGFloat(heading) * CGFloat.pi / 180
        headingImageView.transform = CGAffineTransform(rotationAngle: rotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = 0.001
        region.span.longitudeDelta = 0.001
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addFavorite),
                                               name: .addFavorite,
                                               object: nil)
    }
    
    func setupAds() {
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"//"ca-app-pub-7482106968377175/7907556553"
        bannerView.rootViewController = self
        let request = GADRequest()
        
        bannerView.load(request)
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
