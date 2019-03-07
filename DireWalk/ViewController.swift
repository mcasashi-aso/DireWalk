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

class ViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, MapViewControllerDelegate, CLLocationManagerDelegate, DirectionViewControllerDelegate {
    
    let userDefaults = UserDefaults.standard
    
    let healthStore = HKHealthStore()
    
    let locationManager = CLLocationManager()
    
    enum present: String {
        case direction
        case activity
        case map
    }
    var presentView: present = .direction
    
    var iosControllersHidden = false
    
    var markerLocation = CLLocation()
    
    var userHeadingRadian = CGFloat()
    var destinationHeadingRadian = CGFloat()

    func hideObjects(hide: Bool) {
        if hide {
            hideView.isHidden = false
            UIApplication.shared.isIdleTimerDisabled = true
            iosControllersHidden = true
            setNeedsStatusBarAppearanceUpdate()
            setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.view.bringSubviewToFront(containerView)
        }else {
            hideView.isHidden = true
            UIApplication.shared.isIdleTimerDisabled = false
            iosControllersHidden = false
            setNeedsStatusBarAppearanceUpdate()
            setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.view.bringSubviewToFront(tabStackView)
            self.view.bringSubviewToFront(mapButton)
            self.view.bringSubviewToFront(activityButton)
            self.view.bringSubviewToFront(directionButton)
        }
    }
    
    var arrivalTimer = Timer()
    var count = 0
    func arrivalDestination() {
        hideObjects(hide: false)
        if !arrivalTimer.isValid {
            arrivalTimer = Timer.scheduledTimer(timeInterval: 1,
                                                target: self,
                                                selector: #selector(timeUpdater),
                                                userInfo: nil,
                                                repeats: true)
            let generater = UINotificationFeedbackGenerator()
            generater.prepare()
            generater.notificationOccurred(.warning)
        }else if count > 60 {
            arrivalTimer.invalidate()
            count = 0
        }
    }
    @objc func timeUpdater() {
        count += 1
    }
    
    func updateMarker(markerName: String) {
        markerLocation = CLLocation(latitude: userDefaults.object(forKey: ud.key.annotationLatitude.rawValue) as! CLLocationDegrees,
                                    longitude: userDefaults.object(forKey: ud.key.annotationLongitude.rawValue) as! CLLocationDegrees)
        destinationLabel.setTitle(markerName, for: .normal)
        destinationHeading()
        updateDirectionButton()
        
        arrivalTimer.invalidate()
        count = 0
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
            locationManager.startUpdatingHeading()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userHeadingRadian = CGFloat(newHeading.magneticHeading)
        destinationHeading()
        updateDirectionButton()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        hideObjects(hide: false)
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
        hideObjects(hide: false)
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
        hideObjects(hide: false)
        if view!.isKind(of: DirectionViewController.self) {
            let directionView: DirectionViewController = view as! DirectionViewController
            directionView.distanceLabel.isHidden = false
            directionView.unitLabel.isHidden = false
            presentView = .direction
        }else if view!.isKind(of: MapViewController.self) {
            presentView = .map
        }else if view!.isKind(of: ActivityViewController.self) {
            presentView = .activity
        }else {
            let directionView: DirectionViewController = view as! DirectionViewController
            directionView.distanceLabel.isHidden = false
            directionView.unitLabel.isHidden = false
            presentView = .direction
        }
    }
    
    func getCenter() -> DirectionViewController{
        let sb = UIStoryboard(name: "Direction", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! DirectionViewController
        vc.delegate = self
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
        hideObjects(hide: false)
        contentPageVC.setViewControllers([getCenter()], direction: direction, animated: true, completion: nil)
    }
    @IBAction func tapActivity() {
        if presentView == .activity {  return  }
        presentView = .activity
        hideObjects(hide: false)
        contentPageVC.setViewControllers([getLeft()], direction: .reverse, animated: true, completion: nil)
    }
    @IBAction func tapMap() {
        if presentView == .map {  return  }
        presentView = .map
        hideObjects(hide: false)
        contentPageVC.setViewControllers([getRight()], direction: .forward, animated: true, completion: nil)
    }
    
    @IBAction func tapDestinationLabel() {
        if presentView == .map {
            tapDirection()
        }else {
            tapMap()
        }
    }
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    
    @IBOutlet weak var destinationLabel: UIButton!
    @IBOutlet weak var tabStackView: UIStackView!
    
    @IBOutlet weak var containerView: UIView!
    var contentPageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    let hideView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        containerView.addSubview(contentPageVC.view)
        
        locationManager.delegate = self
        
        if userDefaults.bool(forKey: ud.key.previousAnnotation.rawValue) {
            let latitude: CLLocationDegrees = userDefaults.object(forKey: ud.key.annotationLatitude.rawValue) as! CLLocationDegrees
            let longitude: CLLocationDegrees = userDefaults.object(forKey: ud.key.annotationLongitude.rawValue) as! CLLocationDegrees
            markerLocation = CLLocation(latitude: latitude, longitude: longitude)
        }
        
        askAllowHealth()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return iosControllersHidden
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return iosControllersHidden
    }
    
    func setupViews(){
        let statusbarBackgroundView = UIView()
        statusbarBackgroundView.backgroundColor = UIColor.darkGray
        statusbarBackgroundView.frame = CGRect(x: 0, y: 0,
                                               width: UIScreen.main.bounds.width,
                                               height: UIApplication.shared.statusBarFrame.height)
        self.view.addSubview(statusbarBackgroundView)
        
        directionButton.imageView?.sizeThatFits(CGSize(
            width: Double(directionButton.bounds.width) * 2.0.squareRoot(),
            height: Double(directionButton.bounds.height) * 2.0.squareRoot()))
        
        directionButton.layer.cornerRadius = directionButton.bounds.height / 2
        directionButton.layer.masksToBounds = true
        directionButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        directionButton.layer.shadowRadius = 4
        directionButton.layer.shadowOpacity = 0.5
        let directionButtonImageEdgeInsets = CGFloat(Double(directionButton.bounds.height) - Double(directionButton.bounds.height) / 2.0.squareRoot() / 2.0)
        directionButton.imageEdgeInsets = UIEdgeInsets(top: directionButtonImageEdgeInsets, left: directionButtonImageEdgeInsets, bottom: directionButtonImageEdgeInsets, right: directionButtonImageEdgeInsets)
        activityButton.layer.cornerRadius = activityButton.bounds.height / 2
        activityButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        activityButton.contentMode = UIView.ContentMode.scaleAspectFill
        activityButton.imageEdgeInsets = UIEdgeInsets(top: 0,
                                                      left: 0,
                                                      bottom: 0,
                                                      right: directionButton.bounds.height / 2 / 2)
        mapButton.layer.cornerRadius = mapButton.bounds.height / 2
        mapButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        mapButton.contentMode = UIView.ContentMode.scaleAspectFill
        mapButton.imageEdgeInsets = UIEdgeInsets(top: 0,
                                                 left: directionButton.bounds.height / 2 / 2,
                                                 bottom: 0,
                                                 right: 0)
        destinationLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        addChild(contentPageVC)
        contentPageVC.view.frame = containerView.bounds
        contentPageVC.delegate = self
        contentPageVC.dataSource = self
        contentPageVC.didMove(toParent: self)
        contentPageVC.setViewControllers([getCenter()], direction: .forward, animated: true, completion: nil)
        
        hideView.frame = UIScreen.main.bounds
        hideView.backgroundColor = UIColor.black
        self.view.addSubview(hideView)
        hideView.isHidden = true
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
        healthStore.requestAuthorization(toShare: writeTypes as Set<HKSampleType>, read: readTypes as? Set<HKObjectType>, completion: { success, error in
            if success {
                print("Success")
            } else {
                print("Error")
            }
        })
    }

}
