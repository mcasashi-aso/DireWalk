
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

final class MapViewController: UIViewController, UIScrollViewDelegate, UISearchBarDelegate {
    
    static func create() -> MapViewController {
        let sb = UIStoryboard(name: "Map", bundle: nil)
        return sb.instantiateInitialViewController() as! MapViewController
    }
    
    private let viewModel = ViewModel.shared
    
    // MARK: - Views
    @IBOutlet weak var mapView: ZoomableMapView! {
        didSet {
            if #available(iOS 13, *) {}else {
                mapView.setupMyZoomGesture()
            }
            mapView.userTrackingMode = MKUserTrackingMode.none
            let region: MKCoordinateRegion
            if let saved = viewModel.region {
                region = saved
            } else {
                let center: CLLocationCoordinate2D
                if let selecting = viewModel.coordinate {
                    center = .init(latitude: (viewModel.currentLocation.coordinate.latitude + selecting.latitude) / 2,
                                   longitude: (viewModel.currentLocation.coordinate.longitude + selecting.longitude) / 2)
                }else {
                    center = viewModel.currentLocation.coordinate
                }
                let s = (viewModel.far ?? 1000) / 1000 * 0.015
                let span = MKCoordinateSpan(latitudeDelta: s, longitudeDelta: s)
                region = .init(center: center, span: span)
            }
            mapView.setRegion(region, animated: false)
            mapView.mapType = .mutedStandard
            mapView.delegate = viewModel
        }
    }
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            let bgColor = #colorLiteral(red: 0.7952535152, green: 0.7952535152, blue: 0.7952535152, alpha: 0.4)
            if #available(iOS 13, *) {
                self.searchBar.searchTextField.backgroundColor = bgColor
            }else {
                let textField = searchBar.value(forKey: "_searchField") as! UITextField
                textField.backgroundColor = bgColor
            }
            self.searchBar.accessibilityLabel = "Search Bar"
            self.searchBar.delegate = self
            self.searchBar.placeholder = "search".localized
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
    
    // MARK: - Press Map
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer! {
        didSet { longPressGestureRecognizer.minimumPressDuration = 0.5 }
    }
    @IBAction func pressMap(_ sender: UILongPressGestureRecognizer) {
        print("press map", sender.state)
        guard viewModel.state == .map,
            sender.state == .began else { return }
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        viewModel.setPlace(CLLocation(latitude: coordinate.latitude,
                                      longitude: coordinate.longitude))
    }
    
    // MARK: - Add Marker
    func addMarker(new: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        guard let annotation = viewModel.annotation else { return }
        mapView.addAnnotation(annotation)
        if new {
            let generater = UIImpactFeedbackGenerator()
            generater.prepare()
            generater.impactOccurred()
        }
    }
    
    // MARK: - View's Life Cycle
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
        
        _ = mapView.observe(\.region) { (mapView, changed) in
            self.viewModel.region = changed.newValue
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification?) {
        guard let value = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
            let keyboardHeight = (value as? NSValue)?.cgRectValue.height else { return }
        let homeIndicatorHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        // TODO: 変更に強く書きたかったけど諦め
        let diff = keyboardHeight - (homeIndicatorHeight + 100)
        self.tableView.contentInset.bottom = diff + 40
        self.tableView.scrollIndicatorInsets.bottom = diff + 40
    }
    @objc func keyboardWillHide(_ notification: Notification?) {
        self.tableView.contentInset.bottom = 50
        self.tableView.scrollIndicatorInsets.bottom = 0
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
        userTrackingButton.backgroundColor = .white
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

    // MARK: - Search
    func applyViewConstraints(animated: Bool = true) {
        if viewModel.state == .search {
            tableViewHeightConstranit.constant = mapView.frame.height - searchBar.frame.height
            tableView.contentInset.bottom = 50
            searchBar.setShowsCancelButton(true, animated: true)
            searchBar.cancelButton?.isEnabled = true
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .allowAnimatedContent], animations: {
                self.view.layoutIfNeeded()
                self.userTrackingButton.alpha = 0
                self.compassButton.alpha = 0
                self.scaleView.alpha = 0
                self.tableView.alpha = 1
                self.searchBarBackgroundView.alpha = 1
            })
            tableView.reloadData()
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
    
    // MARK: - Table View Difference
    func reloadTableView(new: [Place], old: [Place]) {
        // TODO: iOS 14 later, replace to UITableViewDifferenceDataSource
        // 上手くできないのと時間の関係もあり、せめてDeleteが綺麗に見えるように1つの編集のみに対応
        // 計算コストも大きいらしいしね
        if #available(iOS 13, *) {
            let difference = new.difference(from: old)
            
            func moveOneRowOnly(_ dif: CollectionDifference<Place>.Change) {
                tableView.beginUpdates()
                switch dif {
                case let .insert(row, _, to):
                    if let toIntdex = to {
                        tableView.moveRow(at: .init(row: row, section: 0),
                                          to: .init(row: toIntdex, section: 0))
                    }else {
                        tableView.insertRows(at: [.init(row: row, section: 0)], with: .automatic)
                    }
                case let .remove(row, _, from):
                    if let fromIndex = from {
                        tableView.moveRow(at: .init(row: fromIndex, section: 0),
                                          to: .init(row: row, section: 0))
                    }else {
                        tableView.deleteRows(at: [.init(row: row, section: 0)], with: .automatic)
                    }
                }
                tableView.endUpdates()
            }
            
            switch difference.count {
            case 0: break
            case 1: moveOneRowOnly(difference.inferringMoves().first!)
            case 2:
                let withMoves = difference.inferringMoves()
                let elements: [Place] = withMoves.map { dif in
                    switch dif {
                    case let .insert(_, ele, _): return ele
                    case let .remove(_, ele, _): return ele
                    }
                }
                if elements[safe: 0] == elements[safe: 1] {
                    // 1つのcellが移動していた場合
                    moveOneRowOnly(withMoves.first!)
                }else {
                    // あるcellが消え、他のcellが入ってきた場合
                    fallthrough
                }
            default:
                tableView.reloadData()
            }
        }else {
            tableView.reloadData()
        }
    }
    
    //　MARK: - Other
    func moveCenterToPlace() {
        let center = viewModel.coordinate ?? viewModel.currentLocation.coordinate
        let s = min((viewModel.far ?? 1000) / 1000 * 0.01, 0.01)
        let span = MKCoordinateSpan(latitudeDelta: s, longitudeDelta: s)
        mapView.setRegion(.init(center: center, span: span), animated: true)
        searchBar.setShowsCancelButton(false, animated: true)
    }

    // MARK: - SearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        viewModel.state = .search
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let nsString = (searchBar.text ?? "") as NSString
        let replaced = nsString.replacingCharacters(in: range, with: text) as String
        viewModel.searchText = replaced.trimmingCharacters(in: .whitespacesAndNewlines)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.state = .map
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if viewModel.searchTableViewPlaces.isEmpty {
            viewModel.state = .map
        }else {
            searchBar.resignFirstResponder()
            searchBar.cancelButton?.isEnabled = true
        }
    }
    
}
