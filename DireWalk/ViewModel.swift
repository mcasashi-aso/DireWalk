//
//  ViewModel.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import MapKit

protocol ViewModelDelegate {
    func updateLabels()
    func didChangeSearchTableViewElements()
    func didChangeState()
    func SearchedTableViewCellSelected()
    func updateActivityViewData(dayChanged: Bool)
}

final class ViewModel: NSObject {
    
    static let shared = ViewModel()
    private override init() {
        super.init()
        self.usingTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(usingTimeUpdater), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeFavorites), name: .didChangeFavorites, object: nil)
    }
    
    private var model = Model.shared
    private var userDefaults = UserDefaults.standard
    var delegate: ViewModelDelegate?
    
    enum Status { case activity, direction, map, search, hideControllers }
    var state : Status = .direction {
        didSet {
            delegate?.didChangeState()
        }
    }
    
    enum Views { case activity, direction, map }
    var presentView: Views {
        switch state {
        case .activity:                    return .activity
        case .direction, .hideControllers: return .direction
        case .map, .search:                return .map
        }
    }
    
    var labelTitle: String {
        guard let place = model.place else {
            switch state {
            case .direction, .activity: return "selectDestination".localized
            case .map: return "longPressToSelect".localized
            case .search: return "enterDestination".localized
            case .hideControllers: return " "
            }
        }
        switch state {
        case .activity: return "Today's Activity"
        case .direction, .map, .search: return place.placeTitle ?? place.address ?? "Pin"
        case .hideControllers: return " "
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
        if state == .hideControllers {
            return NSMutableAttributedString()
        }
        let distanceAttributed: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 80),
            .foregroundColor: UIColor.white
        ]
        let unitAttributed: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 40),
            .foregroundColor : UIColor.white
        ]
        guard model.place != nil else {
            return NSMutableAttributedString(
                string: "swipe".localized,
                attributes: unitAttributed)
        }
        guard (userDefaults.get(.showFar) ?? true) else {
            return NSMutableAttributedString()
        }
        let (far, unit) = model.farDescriprion
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "   ",
                                       attributes: unitAttributed))
        text.append(NSAttributedString(string: far,
                                       attributes: distanceAttributed))
        text.append(NSAttributedString(string: "  \(unit)",
                                       attributes: unitAttributed))
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
        if searchText.isEmpty || searchResults.isEmpty {
            return Array(favoritePlaces).sorted { lhs, rhs in
                guard let l = lhs.placeTitle,
                    let r = rhs.placeTitle else { return true }
                return l > r
            }
        }else {
            return searchResults
        }
    }
    
    // MARK: ViewSettings
    @UserDefault(.arrowColor, defaultValue: 0.75)
    var arrowColor: CGFloat
    @UserDefault(.showFar, defaultValue: true)
    var showFar: Bool
    @UserDefault(.isAlwaysDarkAppearance, defaultValue: true)
    var isAlwaysDarkAppearance: Bool
    
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
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let searchCell = cell as? SearchTableViewCell else { return cell }
        guard searchTableViewPlaces.indices.contains(indexPath.row) else { return searchCell }
        searchCell.setPlace(searchTableViewPlaces[indexPath.row])
        return searchCell
    }
    
    @objc func didChangeFavorites() {
        delegate?.didChangeSearchTableViewElements()
    }
}


// MARK: Using Time
extension ViewModel {
    @objc func usingTimeUpdater() {
        let dayChanged = !date.isSameDay(to: Date())
        if dayChanged {
            usingTime = 0
        }
        usingTime += 1
        
        // 1分毎に
        if ceil(Double(usingTime) / 60) != ceil(Double(usingTime + 1) / 60) {
            delegate?.updateActivityViewData(dayChanged: dayChanged)
        }
    }
}
