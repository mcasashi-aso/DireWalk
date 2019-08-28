
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

class MapViewController: UIViewController, UIScrollViewDelegate {
    
    private let userDefaults = UserDefaults.standard
    private let viewModel = ViewModel.shared
    private let model = Model.shared
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let annotation = MKPointAnnotation()
    
    @IBOutlet weak var bannerView: GADBannerView! {
        didSet{
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
        }
    }
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer! {
        didSet {
            longPressGestureRecognizer.minimumPressDuration = 0.5
        }
    }
    @IBAction func pressMap(_ sender: UILongPressGestureRecognizer) {
        if viewModel.model.locationManager.location == nil { return }
        guard sender.state == .began else { return }
        let location = sender.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        model.setPlace(CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude))
    }
    
    func addMarker(new: Bool) {
        mapView.removeAnnotation(annotation)
        
        wait( { self.viewModel.model.place == nil } ) {
            self.annotation.coordinate = self.model.coordinate
            let place = self.viewModel.model.place
            self.annotation.title = place?.placeTitle
            
            self.mapView.addAnnotation(self.annotation)
        }
        
        if new {
            let generater = UIImpactFeedbackGenerator()
            generater.prepare()
            generater.impactOccurred()
        }
    }
    
    private var headingImageView = UIImageView(image: UIImage(named: "UserHeading"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = viewModel.model
        mapView.userTrackingMode = MKUserTrackingMode.none
        var region: MKCoordinateRegion = mapView.region
        region.center = viewModel.model.currentLocation.coordinate
        region.span.latitudeDelta = 0.004
        region.span.longitudeDelta = 0.004
        mapView.setRegion(region, animated: true)
        mapView.mapType = .mutedStandard
        
        setupMapButtons()
        
        addMarker(new: false)
        
        setupGesture()
        setupAds()
    }
    
    // ドラッグの位置記憶用の変数
    private var dragPoint: CGPoint?
    private func setupGesture() {
        let doubleLongPress = UILongPressGestureRecognizer(target: self, action: #selector(doubleLongPress(_:)))
        
        // ダブルタップ後、即座にLongPress状態に移るように
        doubleLongPress.minimumPressDuration = 0
        doubleLongPress.numberOfTapsRequired = 1
        
        mapView.addGestureRecognizer(doubleLongPress)
        
        doubleLongPress.delegate = self
        
        // MKMapViewの機能が実装してあるSubViewを引っ張ってきて、設定してあるDoubleTapGestureRecognizerにdelegateを設定する
        mapView.subviews[0].gestureRecognizers?.forEach({ element in
            if let recognizer = (element as? UITapGestureRecognizer),
                recognizer.numberOfTapsRequired == 2 {
                element.delegate = self
            }
        })
    }
    
    private func setupMapButtons() {
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
}

// MARK: HeadingView
extension MapViewController {
    func addHeadingView(to annotationView: MKAnnotationView) {
        headingImageView.frame = CGRect(x: (annotationView.frame.size.width - 40)/2,
                                        y: (annotationView.frame.size.height - 40)/2,
                                        width: 40, height: 40)
        annotationView.insertSubview(headingImageView, at: 0)
    }
    
    func updateHeadingImageView() {
        let rotation = (model.userHeadingRadian - CGFloat(mapView.camera.heading)) * .pi / 180
        headingImageView.transform = CGAffineTransform(rotationAngle: rotation)
    }
}

// 片手でzoom可能にする(標準MapLike)
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

// GADBannerViewDelegate
extension MapViewController: GADBannerViewDelegate {
    
    func setupAds() {
        bannerView.adUnitID = "ca-app-pub-7482106968377175/7907556553"
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["08414f421dd5519a221bf0414a3ec95e"]
        bannerView.load(request)
    }
}
