//
//  ViewModel.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import MapKit

protocol ViewModelDelegate: class {
    func addHeadingView(to annotationView: MKAnnotationView)
    
    func updateLabels()
    func didChangeSearchTableViewElements()
    func didChangePlace()
    func didChangeState()
    func didChangeRotation()
    
    func presentationEditPlaceView(place: Place)
    func SearchedTableViewCellSelected()
    func updateActivityViewData(dayChanged: Bool)
}

final class ViewModel: NSObject {
    
    static let shared = ViewModel()
    private override init() {
        super.init()
        model.delegate = self
        self.usingTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(usingTimeUpdater), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeFavorites), name: .didChangeFavorites, object: nil)
    }
    
    private let model = Model.shared
    private var userDefaults = UserDefaults.standard
    weak var delegate: ViewModelDelegate?
    
    enum Status { case activity, direction, map, search, hideControllers }
    var state : Status = .direction {
        didSet {
            delegate?.didChangeState()
            UIApplication.shared.isIdleTimerDisabled = (state == .hideControllers)
        }
    }
    
    // TODO: いつかLabelのSwipe中の中間表現もつけてフルイドインターフェースさせたい
    // https://codeday.me/jp/qa/20190314/417737.html
    var swiping = false
    
    enum Views { case activity, direction, map }
    var presentView: Views {
        switch state {
        case .activity: return .activity
        case .direction, .hideControllers: return .direction
        case .map, .search: return .map
        }
    }
    
    var labelTitle: String {
        guard let place = model.place else {
            switch state {
            case .direction, .hideControllers, .activity: return "selectDestination".localized
            case .map: return "longPressToSelect".localized
            case .search: return "enterDestination".localized
            }
        }
        switch state {
        case .activity: return "Today's Activity"
        case .direction, .hideControllers, .map, .search:
            return place.placeTitle ?? place.address ?? "Pin"
        }
    }
    var aboutLabelText: String {
        if model.place == nil { return " " }
        switch state {
        case .activity, .hideControllers: return " "
        case .direction, .map: return "destination".localized
        case .search: return "search".localized
        }
    }
    var farLabelText: NSMutableAttributedString {
        guard model.place != nil else {
            return NSMutableAttributedString(attributedString:
                .get("swipe".localized, attributes: .white40))
        }
        
        let (far, unit) = { () -> (String, String) in
            guard let far = model.far else { return ("Error", "  ") }
            switch Int(far) {
            case ..<100:  return (String(Int(far)), "m")
            case ..<1000: return (String((Int(far) / 10 + 1) * 10), "m")
            default:
                let double = Double(Int(far) / 100 + 1) / 10
                if double.truncatingRemainder(dividingBy: 1.0) == 0.0 {
                    return (String(Int(double)), "km")
                }else { return (String(double),  "km") }
            }
        }()
        let text = NSMutableAttributedString()
        text.append(NSAttributedString.get("  ", attributes: .white40))
        text.append(NSAttributedString.get(far, attributes: .white80))
        text.append(NSAttributedString.get(" \(unit)", attributes: .white40))
        return text
    }
    
    var headingImageAngle: CGFloat {
        model.place != nil ? (model.heading * .pi / 180) : (.pi / 2)
    }
    var buttonAngle: CGFloat { (model.heading - 45) * .pi / 180 }
    
    var annotation: Annotation?
    
    @UserDefault(.favoritePlaces, defaultValue: Set<Place>())
    var favoritePlaces: Set<Place>
    var searchText = "" { didSet { setResultElements() } }
    var searchResults = [Place]() {
        didSet { delegate?.didChangeSearchTableViewElements() }
    }
    var searchTableViewPlaces: [Place] {
        let isEmpty = searchText.isEmpty || searchResults.isEmpty
        let array = isEmpty ? Array(favoritePlaces) : searchResults
        return array.sorted { lhs, rhs in
            let location = model.currentLocation
            return lhs.distance(from: location) < rhs.distance(from: location)
        }
    }
    
    var settings = Settings.shared
    
    var usingTimer = Timer()
    @UserDefault(.usingTimes, defaultValue: 0)
    var usingTime: Int
    @UserDefault(.date, defaultValue: Date())
    var date: Date
}


// MARK: UIPageVCDelegate
extension ViewModel: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        let vc = pageViewController.viewControllers?.first
        switch vc {
        case is DirectionViewController: state = .direction
        case is MapViewController:       state = .map
        case is ActivityViewController:  state = .activity
        default: return
        }
        delegate?.updateLabels()
    }
}


// MARK: UISearchBarDelegate
extension ViewModel: UISearchBarDelegate {
    func setResultElements() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: model.coordinate,
                                            latitudinalMeters: 10_000,
                                            longitudinalMeters: 10_000)     // 10km四方
        MKLocalSearch(request: request).start { (result, error) in
            guard let mapItems = result?.mapItems, error == nil else { return }
            let results = mapItems.map { item in
                Place(coordinate: item.placemark.coordinate,
                      placeTitle: item.name ?? item.placemark.title ?? item.placemark.address,
                      adress: item.placemark.address)
            }
            if !results.isEmpty {
                self.searchResults = results
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        state = .search
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let nsString = (searchBar.text ?? "") as NSString
        searchText = nsString.replacingCharacters(in: range, with: text) as String
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        state = .map
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        setResultElements()
        if (searchBar.text?.isEmpty ?? false) || searchTableViewPlaces.isEmpty {
            // 検索結果がない場合検索モードを終了する
            state = .map
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        }else {
            // 検索結果がある場合はキーボードだけ消す
            searchBar.resignFirstResponder()
            if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
    }
    
}
// MARK: SearchTableViewDelegate
extension ViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        model.place = searchTableViewPlaces[indexPath.row]
        state = .map
        delegate?.SearchedTableViewCellSelected()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: SearchTableDataSource
extension ViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        searchTableViewPlaces.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let searchCell = cell as? SearchTableViewCell else { return cell }
        guard let place = searchTableViewPlaces[safe: indexPath.row] else { return searchCell }
        searchCell.setPlace(place)
        return searchCell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard var place = self.searchTableViewPlaces[safe: indexPath.row] else { return nil }
        let toEditAction = UIContextualAction(style: .normal, title: "Edit") {
            (action, view, completion) in
            // delegate.presentationEditPlaceView(place: place)
        }
        let toggleFavoriteAction = UIContextualAction(style: .normal, title: "Favorite") {
            (action, view, completion) in
            place.isFavorite.toggle()
        }
        let actions = place.isFavorite ? [toEditAction, toggleFavoriteAction] : [toggleFavoriteAction]
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    @objc func didChangeFavorites() {
        print(favoritePlaces)
        delegate?.didChangeSearchTableViewElements()
    }
}


// MARK: Using Time
extension ViewModel {
    @objc func usingTimeUpdater() {
        let now = Date()
        let dayChanged = !date.isSameDay(to: now)
        if dayChanged { usingTime = 0 }
        usingTime += 1
        
        // 1分毎に
        if ceil(Double(usingTime) / 60) != ceil(Double(usingTime + 1) / 60) {
            delegate?.updateActivityViewData(dayChanged: dayChanged)
        }
        date = now
    }
}


// MARK: MKMapViewDelegate
extension ViewModel: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView.canShowCallout = true
        pinView.annotation = annotation
        pinView.animatesWhenAdded = true
        
        if let an = annotation as? Annotation {
            pinView.rightCalloutAccessoryView = getAnnotationButton(annotation: an)
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard control == view.rightCalloutAccessoryView,
            let an = view.annotation as? Annotation else { return }
        an.place?.isFavorite.toggle()
        view.rightCalloutAccessoryView = getAnnotationButton(annotation: an)
    }
    
    func getAnnotationButton(annotation: Annotation) -> UIButton? {
        guard let place = annotation.place else { return nil }
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        if #available(iOS 13, *) {
            let name = place.isFavorite ? "heart.fill" : "heart"
            let image = UIImage(systemName: name)!
            button.setImage(image, for: .normal)
        }else {
            let name = place.isFavorite ? "HeartFill" : "Heart"
            let image = UIImage(named: name)!.withRenderingMode(.alwaysTemplate)
            button.setImage(image, for: .normal)
            button.tintColor = .systemBlue
        }
        return button
    }
    
    func mapView(_ mapView: MKMapView,
                 didAdd views: [MKAnnotationView]) {
        if views.last?.annotation is MKUserLocation {
            delegate?.addHeadingView(to: views.last!)
        }
    }
    
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated animated: Bool) {
        delegate?.didChangeRotation()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        delegate?.didChangeRotation()
    }
}


// MARK: ModelDelegate
extension ViewModel: ModelDelegate {   
    func didChangePlace() {
        delegate?.didChangeRotation()
        delegate?.updateLabels()
        delegate?.didChangePlace()
    }
    
    func didChangeFar() {
        delegate?.updateLabels()
    }
    
    func didChangeHeading() {
        delegate?.didChangeRotation()
    }
}
