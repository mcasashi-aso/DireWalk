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
}

class ViewModel: NSObject {
    
    static let shared = ViewModel()
    private override init() {
        super.init()
    }
    
    var model = Model.shared
    var delegate: ViewModelDelegate?
    
    enum Status { case activity, direction, map, search, favorite, hideControllers }
    var state : Status = .direction
    
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
        case .direction, .map: return place.placeTitle ?? place.adress ?? "Pin"
        case .search, .favorite: return "Enter Destination //"
        case .hideControllers: return " "
        }
    }
    var aboutLabelText: String {
        if model.place == nil || UserDefaults.standard.bool(forKey: udKey.showFar.rawValue) { return " " }
        switch state {
        case .activity, .hideControllers: return " "
        case .direction, .map: return NSLocalizedString("destination", comment: "")
        case .search, .favorite: return "Search //"
        }
    }
    
    var farLabelText: NSMutableAttributedString {
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
    
    var searchText = ""
}


extension ViewModel {
    
}


// MARK: UIPageVCDataSource
extension ViewModel: UIPageViewControllerDataSource {
    func getDirectionVC() -> DirectionViewController{
        let sb = UIStoryboard(name: "Direction", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! DirectionViewController
        return vc
    }
    func getMapVC() -> MapViewController{
        let sb = UIStoryboard(name: "Map", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! MapViewController
        return vc
    }
    func getActivityVC() -> ActivityViewController{
        let sb = UIStoryboard(name: "Activity", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! ActivityViewController
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is ActivityViewController:  return nil
        case is DirectionViewController: return getActivityVC()
        case is MapViewController:       return getDirectionVC()
        default: return nil
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is MapViewController:       return nil
        case is DirectionViewController: return getMapVC()
        case is ActivityViewController:  return getDirectionVC()
        default: return nil
        }
     }
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

