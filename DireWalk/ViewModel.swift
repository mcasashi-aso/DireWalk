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
    func hideControllers(_ isHidden: Bool)
}

class ViewModel: NSObject {
    
    static let shared = ViewModel()
    private override init() {
        super.init()
    }
    
    private var model = Model.shared
    var delegate: ViewModelDelegate?
    
    enum Status { case activity, direction, map, search, favorite, hideControllers }
    var state : Status = .direction {
        didSet {
            delegate?.hideControllers(state == .hideControllers)
        }
    }
    
    enum Views { case activity, direction, map }
    var presentView: Views {
        switch state {
        case .activity:                    return .activity
        case .direction, .hideControllers: return .direction
        case .map, .search, .favorite:     return .map
        }
    }
    
    var labelTitle: String {
        guard let place = model.place else {
            switch state {
            case .direction, .activity: return NSLocalizedString("selectDestination", comment: "")
            case .map: return NSLocalizedString("longPressToSelect", comment: "")
            case .search, .favorite: return "Enter Destination //"
            case .hideControllers: return " "
            }
        }
        
        switch state {
        case .activity: return "Today's Activity"
        case .direction, .map: return place.placeTitle ?? place.address ?? "Pin"
        case .search, .favorite: return "Enter Destination //"
        case .hideControllers: return " "
        }
    }
    var aboutLabelText: String {
        let showFar = UserDefaults.standard.get(.showFar) ?? true
        if model.place == nil || showFar { return " " }
        switch state {
        case .activity, .hideControllers: return " "
        case .direction, .map: return NSLocalizedString("destination", comment: "")
        case .search, .favorite: return "Search //"
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
                string: NSLocalizedString("swipe", comment: ""),
                attributes: unitAttributed)
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
    
    var headingImageAngle: CGFloat { model.heading * .pi / 180 }
    var buttonAngle: CGFloat { (model.heading - 45) * .pi / 180 }
    
    var annotation: Annotation?
    
    @UserDefault(.favoritePlaces, defaultValue: Set<Place>())
    var favoritePlaces: Set<Place>
    var searchText = "" {
        didSet { setResultElements() }
    }
    var resultElements = [Place]() {
        didSet { delegate?.didChangeSearchTableViewElements() }
    }
    
    // MARK: ViewSettings
    @UserDefault(.arrowColor, defaultValue: 0.75)
    var arrowColor: CGFloat
    @UserDefault(.showFar, defaultValue: true)
    var showFar: Bool
    @UserDefault(.isAlwaysDarkAppearance, defaultValue: false)
    var isAlwaysDarkAppearance: Bool
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
        if searchText.isEmpty {
            resultElements = Array(favoritePlaces.sorted(by: { (lhs, rhs) -> Bool in
                guard let l = lhs.placeTitle, let r = rhs.placeTitle else  { return true }
                return l < r
            }))
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: model.coordinate,
                                            latitudinalMeters: 10_000,
                                            longitudinalMeters: 10_000)     // 10km四方
        MKLocalSearch(request: request).start { (result, error) in
            guard let mapItems = result?.mapItems, error != nil else {
                self.resultElements = []
                return
            }
            self.resultElements = mapItems.map { item in
                Place(coordinate: item.placemark.coordinate,
                      placeTitle: item.name ?? item.placemark.title ?? item.placemark.address,
                      adress: item.placemark.address)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
}
