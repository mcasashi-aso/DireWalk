
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
    
    static func create() -> MapViewController {
        let sb = UIStoryboard(name: "Map", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! MapViewController
        return vc
    }
    
    private let viewModel = ViewModel.shared
    private let model = Model.shared
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBarBackgroundView: UIView!
    
    @IBOutlet weak var tableViewHeightConstranit: NSLayoutConstraint!
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer! {
        didSet {
            longPressGestureRecognizer.minimumPressDuration = 0.5
        }
    }
    @IBAction func pressMap(_ sender: UILongPressGestureRecognizer) {
        if model.locationManager.location == nil { return }
        guard sender.state == .began else { return }
        let location = sender.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        model.setPlace(CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude))
    }
    
    func addMarker(new: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        
        wait( { self.model.place == nil } ) {
            self.viewModel.annotation = Annotation(place: self.model.place!)
            self.mapView.addAnnotation(self.viewModel.annotation!)
        }
        
        if new {
            let generater = UIImpactFeedbackGenerator()
            generater.prepare()
            generater.impactOccurred()
        }
    }
    
    private var headingImageView = UIImageView(image: UIImage(named: "UserHeading")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = model
        searchBar.delegate = viewModel
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        
        setupMapView()
        setupMapButtons()
        setupGesture()
        setupSearchBar()
        
        addMarker(new: false)
        
        applyViewConstraints(animated: false)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification?) {
        guard let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        tableView.contentInset.bottom = rect.height + 40
    }
    @objc func keyboardWillHide(_ notification: Notification?) {
        tableView.contentInset.bottom = 40
    }
    
    // ドラッグの位置記憶用の変数
    private var dragPoint: CGPoint?
    
    var userTrackingButton: MKUserTrackingButton!
    var compassButton: MKCompassButton!
    var scaleView: MKScaleView!
    
    private func setupSearchBar() {
        let bgColor = #colorLiteral(red: 0.7952535152, green: 0.7952535152, blue: 0.7952535152, alpha: 0.4)
        if #available(iOS 13, *) {
            searchBar.searchTextField.backgroundColor = bgColor
        }else {
            let textField = searchBar.value(forKey: "_searchField") as! UITextField
            textField.backgroundColor = bgColor
        }
    }
    private func setupMapView() {
        mapView.userTrackingMode = MKUserTrackingMode.none
        var region: MKCoordinateRegion = mapView.region
        region.center = CLLocationCoordinate2DMake(model.currentLocation.coordinate.latitude,
                                                   model.currentLocation.coordinate.longitude)
        region.center = model.currentLocation.coordinate
        region.span.latitudeDelta = 0.004
        region.span.longitudeDelta = 0.004
        mapView.setRegion(region, animated: true)
        mapView.mapType = .mutedStandard
    }
    private func setupMapButtons() {
        let screenWidth = UIScreen.main.bounds.width
        let searchBarHeight = searchBar.frame.height
        
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.backgroundColor = UIColor.white
        let userTrackingButtonWidth = userTrackingButton.bounds.width
        userTrackingButton.frame = CGRect(
            origin: CGPoint(x: screenWidth - userTrackingButtonWidth - 3,
                            y: searchBarHeight + 3),
            size: userTrackingButton.bounds.size)
        userTrackingButton.layer.cornerRadius = userTrackingButton.bounds.height / 6
        userTrackingButton.layer.masksToBounds = true
        userTrackingButton.layer.shadowColor = UIColor.black.cgColor
        userTrackingButton.layer.shadowOpacity = 0.5
        userTrackingButton.layer.shadowRadius = 4
        
        self.view.addSubview(userTrackingButton)
        
        compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .adaptive
        let compassButtonWidth = compassButton.bounds.width
        
        compassButton.frame = CGRect(
            origin: CGPoint(x: screenWidth - compassButtonWidth - 4,
                            y: userTrackingButton.frame.maxY + 4),
            size: compassButton.bounds.size)
        self.view.addSubview(compassButton)
        
        scaleView = MKScaleView(mapView: mapView)
        scaleView.scaleVisibility = .adaptive
        scaleView.frame = CGRect(
            origin: CGPoint(x: 10, y: searchBarHeight + 4),
            size: scaleView.bounds.size)
        self.view.addSubview(scaleView)
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

// MARK: 片手でzoom可能にする(標準MapLike)
extension MapViewController: UIGestureRecognizerDelegate {
    private func setupGesture() {
        let doubleLongPress = UILongPressGestureRecognizer(target: self, action: #selector(doubleLongPress(_:)))
        
        // ダブルタップ後、即座にLongPress状態に移るように
        doubleLongPress.minimumPressDuration = 0
        doubleLongPress.numberOfTapsRequired = 1
        
        mapView.addGestureRecognizer(doubleLongPress)
        
        doubleLongPress.delegate = self
        
        // MKMapViewの機能が実装してあるSubViewを引っ張ってきて、
        // 設定してあるDoubleTapGestureRecognizerにdelegateを設定する
        mapView.subviews[0].gestureRecognizers?.forEach({ element in
            if let recognizer = (element as? UITapGestureRecognizer),
                recognizer.numberOfTapsRequired == 2 {
                element.delegate = self
            }
        })
    }
    
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

// MARK: Search
extension MapViewController {
    func applyViewConstraints(animated: Bool = true) {
        if viewModel.state == .search {
            tableViewHeightConstranit.constant = mapView.frame.height - searchBar.frame.height - 40
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .allowAnimatedContent], animations: {
                self.view.layoutIfNeeded()
                self.userTrackingButton.alpha = 0
                self.compassButton.alpha = 0
                self.scaleView.alpha = 0
                self.tableView.alpha = 1
                self.searchBarBackgroundView.alpha = 1
            })
        }else {
            tableViewHeightConstranit.constant = 0
            UIView.animate(withDuration: animated ? 0.28 : 0, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .allowAnimatedContent], animations: {
                self.view.layoutIfNeeded()
                self.userTrackingButton.alpha = 1
                self.compassButton.alpha = 1
                self.scaleView.alpha = 1
                self.tableView.alpha = 0
                self.searchBarBackgroundView.alpha = 0
            })
            searchBar.resignFirstResponder()
        }
    }
    
    func searchedTableViewCellSelected() {
        mapView.setCenter(model.coordinate, animated: true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
