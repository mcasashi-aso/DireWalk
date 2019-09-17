
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

final class MapViewController: UIViewController, UIScrollViewDelegate {
    
    static func create() -> MapViewController {
        let sb = UIStoryboard(name: "Map", bundle: nil)
        return sb.instantiateInitialViewController() as! MapViewController
    }
    
    private let viewModel = ViewModel.shared
    private let model = Model.shared
    
    // MARK: - Views
    @IBOutlet weak var mapView: ZoomableMapView! {
        didSet {
            if #available(iOS 13, *) {}else {
                mapView.setupGesture()
            }
            mapView.userTrackingMode = MKUserTrackingMode.none
            var region: MKCoordinateRegion = mapView.region
            region.center = model.currentLocation.coordinate
            region.span.latitudeDelta = 0.004
            region.span.longitudeDelta = 0.004
            mapView.setRegion(region, animated: false)
            mapView.mapType = .mutedStandard
            mapView.delegate = viewModel
        }
    }
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            let bgColor = #colorLiteral(red: 0.7952535152, green: 0.7952535152, blue: 0.7952535152, alpha: 0.4)
            if #available(iOS 13, *) {
                searchBar.searchTextField.backgroundColor = bgColor
            }else {
                let textField = searchBar.value(forKey: "_searchField") as! UITextField
                textField.backgroundColor = bgColor
            }
            searchBar.accessibilityLabel = "Search Bar"
            searchBar.delegate = viewModel
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = 70
            tableView.delegate = viewModel
            tableView.dataSource = viewModel
        }
    }
    
    @IBOutlet weak var searchBarBackgroundView: UIView!
    @IBOutlet weak var tableViewHeightConstranit: NSLayoutConstraint!
    
    private var headingImageView = UIImageView(image: UIImage(named: "UserHeading")!)
    
    // MARK: - Press Map
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer! {
        didSet { longPressGestureRecognizer.minimumPressDuration = 0.5 }
    }
    @IBAction func pressMap(_ sender: UILongPressGestureRecognizer) {
        guard viewModel.state == .map,
            sender.state == .began else { return }
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        model.setPlace(CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude))
    }
    
    // MARK: - Add Marker
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
    
    // MARK: View's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapButtons()
        handleSwipeDelegate()
        
        addMarker(new: false)
        applyViewConstraints(animated: false)
        
        tableView.register(SearchTableViewCell.self)
        
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
    
    // MARK: - Map's Buttons
    var userTrackingButton: MKUserTrackingButton!
    var compassButton: MKCompassButton!
    var scaleView: MKScaleView!
    
    private func setupMapButtons() {
        let screenWidth = UIScreen.main.bounds.width
        let searchBarHeight = searchBar.frame.height
        
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        let userTrackingButtonWidth = userTrackingButton.bounds.width
        userTrackingButton.frame = CGRect(origin: CGPoint(x: screenWidth - userTrackingButtonWidth - 3,
                                                          y: searchBarHeight + 3),
                                          size: userTrackingButton.bounds.size)
        // TODO: COlOR
        userTrackingButton.backgroundColor = .background
        userTrackingButton.layer.cornerRadius = userTrackingButton.bounds.height / 6
        userTrackingButton.layer.masksToBounds = true
        userTrackingButton.layer.shadowColor = UIColor.black.cgColor
        userTrackingButton.layer.shadowOpacity = 0.5
        userTrackingButton.layer.shadowRadius = 4
        self.view.addSubview(userTrackingButton)
        
        compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .adaptive
        let compassButtonWidth = compassButton.bounds.width
        compassButton.frame = CGRect(origin: CGPoint(x: screenWidth - compassButtonWidth - 4,
                                                     y: userTrackingButton.frame.maxY + 8),
                                     size: compassButton.bounds.size)
        self.view.addSubview(compassButton)
        
        scaleView = MKScaleView(mapView: mapView)
        scaleView.scaleVisibility = .adaptive
        scaleView.frame = CGRect(origin: CGPoint(x: 10, y: searchBarHeight + 4),
                                 size: scaleView.bounds.size)
        self.view.addSubview(scaleView)
    }
    
    // MARK: - Swipe handler
    func handleSwipeDelegate() {
        guard let pageVC = parent as? UIPageViewController else { return }
        pageVC.scrollView?.canCancelContentTouches = false
        tableView.gestureRecognizers?.forEach { recognizer in
            let name = String(describing: type(of: recognizer))
            guard name == "_UISwipeActionPanGestureRecognizer" else { return }
            pageVC.scrollView?.panGestureRecognizer.require(toFail: recognizer)
        }
    }
}

// MARK: - HeadingView
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

// MARK: - Search
extension MapViewController {
    func applyViewConstraints(animated: Bool = true) {
        if viewModel.state == .search {
            tableViewHeightConstranit.constant = mapView.frame.height - searchBar.frame.height - 40
            searchBar.setShowsCancelButton(true, animated: true)
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
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchedTableViewCellSelected() {
        mapView.setCenter(model.coordinate ?? model.currentLocation.coordinate, animated: true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
