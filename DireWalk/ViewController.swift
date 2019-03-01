//
//  ViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import HealthKit
import CoreLocation

class ViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, MapViewControllerDelegate, CLLocationManagerDelegate {
    
    let userDefaults = UserDefaults.standard
    
    let healthStore = HKHealthStore()
    
    let locationManager = CLLocationManager()
    
    enum present: String {
        case direction
        case activity
        case map
    }
    var presentView: present = .direction
    
    var markerLocation = CLLocation()
    
    var userHeadingRadian = CGFloat()
    var destinationHeadingRadian = CGFloat()
    
    
    func updateMarker() {
        markerLocation = CLLocation(latitude: userDefaults.object(forKey: ud.key.annotationLatitude.rawValue) as! CLLocationDegrees,
                                    longitude: userDefaults.object(forKey: ud.key.annotationLongitude.rawValue) as! CLLocationDegrees)
        destinationHeading()
        updateDirectionButton()
    }
    
    func destinationHeading() {
        let destinationLatitude = toRadian(markerLocation.coordinate.latitude)
        let destinationLongitude = toRadian(markerLocation.coordinate.longitude)
        let userLatitude = toRadian((locationManager.location?.coordinate.latitude)!)
        let userLongitude = toRadian((locationManager.location?.coordinate.longitude)!)
        
        let difLongitude = destinationLongitude - userLongitude
        let y = sin(difLongitude)
        let x = cos(userLatitude) * tan(destinationLatitude) - sin(userLatitude) * cos(difLongitude)
        let p = atan2(y, x) * 180 / CGFloat.pi
        if p < 0 {
            destinationHeadingRadian = 360 + p
        }
        destinationHeadingRadian = p
    }
    
    func toRadian(_ angle: CLLocationDegrees) -> CGFloat{
        let floatAngle = CGFloat(angle)
        return floatAngle * CGFloat.pi / 180
    }
    
    func updateDirectionButton() {
        let directoinButtonHeading = destinationHeadingRadian - userHeadingRadian
        userDefaults.set(directoinButtonHeading, forKey: ud.key.directoinButtonHeading.rawValue)
        directionButton.imageView?.transform = CGAffineTransform(rotationAngle: directoinButtonHeading * CGFloat.pi / 180)
    }
    
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
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userHeadingRadian = CGFloat(newHeading.magneticHeading)
        updateDirectionButton()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: ActivityViewController.self) {
            return nil
        }else if viewController.isKind(of: DirectionViewController.self) {
            return getLeft()
        }else if viewController.isKind(of: MapViewController.self) {
            return getCenter()
        }
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: MapViewController.self) {
            return nil
        }else if viewController.isKind(of: DirectionViewController.self) {
            return getRight()
        }else if viewController.isKind(of: ActivityViewController.self) {
            return getCenter()
        }
        return nil
     }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let view = pageViewController.viewControllers?.first
        if view!.isKind(of: DirectionViewController.self) {
            presentView = .direction
        }else if view!.isKind(of: MapViewController.self) {
            presentView = .map
        }else if view!.isKind(of: ActivityViewController.self) {
            presentView = .activity
        }else {
            presentView = .direction
        }
    }
    
    func getCenter() -> DirectionViewController{
        let sb = UIStoryboard(name: "Direction", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! DirectionViewController
        return vc
    }
    func getRight() -> MapViewController{
        let sb = UIStoryboard(name: "Map", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! MapViewController
        vc.delegate = self
        return vc
    }
    func getLeft() -> ActivityViewController{
        let sb = UIStoryboard(name: "Activity", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! ActivityViewController
        return vc
    }
    
    @IBAction func tapDirection() {
        if presentView == .direction {  return  }
        var direction: UIPageViewController.NavigationDirection = .forward
        if presentView == .activity {
            direction = UIPageViewController.NavigationDirection.forward
        }else {
            direction = UIPageViewController.NavigationDirection.reverse
        }
        presentView = .direction
        contentPageVC.setViewControllers([getCenter()], direction: direction, animated: true, completion: nil)
    }
    @IBAction func tapActivity() {
        if presentView == .activity {  return  }
        presentView = .activity
        contentPageVC.setViewControllers([getLeft()], direction: .reverse, animated: true, completion: nil)
    }
    @IBAction func tapMap() {
        if presentView == .map {  return  }
        presentView = .map
        contentPageVC.setViewControllers([getRight()], direction: .forward, animated: true, completion: nil)
    }
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var tabStackView: UIStackView!
    
    @IBOutlet weak var containerView: UIView!
    var contentPageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        containerView.addSubview(contentPageVC.view)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupViews(){
        directionButton.imageView?.sizeThatFits(CGSize(
            width: Double(directionButton.bounds.width) * 2.0.squareRoot(),
            height: Double(directionButton.bounds.height) * 2.0.squareRoot()))
        
        tabStackView.layer.cornerRadius = tabStackView.bounds.height / 2
        tabStackView.layer.masksToBounds = true
        tabStackView.layer.shadowOffset = CGSize(width: 1, height: 1)
        tabStackView.layer.shadowRadius = 4
        tabStackView.layer.shadowOpacity = 0.5
        directionButton.layer.cornerRadius = directionButton.bounds.height / 2
        directionButton.layer.masksToBounds = true
        directionButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        directionButton.layer.shadowRadius = 4
        directionButton.layer.shadowOpacity = 0.5
        activityButton.layer.cornerRadius = activityButton.bounds.height / 2
        activityButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        mapButton.layer.cornerRadius = mapButton.bounds.height / 2
        mapButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        endButton.layer.cornerRadius = endButton.bounds.height / 4
        endButton.layer.masksToBounds = true
        
        contentPageVC.setViewControllers([getCenter()], direction: .forward, animated: true, completion: nil)
        addChild(contentPageVC)
        contentPageVC.view.frame = containerView.bounds
        contentPageVC.delegate = self
        contentPageVC.dataSource = self
        contentPageVC.didMove(toParent: self)
    }
    
    func askAllowHealth() {
        let readTypes = Set([
            HKWorkoutType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)
            ])
        let writeTypes = Set([
            HKWorkoutType.workoutType()
            ])
        healthStore.requestAuthorization(toShare: writeTypes as! Set<HKSampleType>, read: readTypes as! Set<HKObjectType>, completion: { success, error in
            if success {
                print("Success")
            } else {
                print("Error")
            }
        })
    }

}
