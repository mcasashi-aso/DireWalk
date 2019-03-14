//
//  ViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

class ViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, MapViewControllerDelegate, CLLocationManagerDelegate, DirectionViewControllerDelegate {
    
    let userDefaults = UserDefaults.standard
    
    let locationManager = CLLocationManager()
    
    let healthStore = HKHealthStore()
    
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
    
    let selectDestination = NSLocalizedString("selectDestination", comment: "")
    let longPressToSelect = NSLocalizedString("longPressToSelect", comment: "")
    var destinationName: String!
    let activity = "Today's Activity"

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
        destinationName = markerName
        userDefaults.set(destinationName, forKey: ud.key.destinationName.rawValue)
        destinationLabel.setTitle(destinationName, for: .normal)
        destinationHeading()
        updateDirectionButton()
        
        arrivalTimer.invalidate()
        count = 0
        
        print("here")
        
        let views = contentPageVC.viewControllers
        for view in views! {
            print(view)
            if view.isKind(of: DirectionViewController.self) {
                let directionView = view as! DirectionViewController
                directionView.getDestinationLocation()
                directionView.updateFar()
                print("direction")
            }
        }
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
        directionButton.transform = CGAffineTransform(rotationAngle: (directoinButtonHeading - 45) * CGFloat.pi / 180)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            askAllowHealth()
        default:
            let sb = UIStoryboard(name: "RequestLocation", bundle: nil)
            let view = sb.instantiateInitialViewController()
            self.present(view!, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let now = Date()
        userDefaults.set(now, forKey: "date")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userHeadingRadian = CGFloat(newHeading.magneticHeading)
        destinationHeading()
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
        showDestinationLabel.text = NSLocalizedString("destination", comment: "")
        destinationLabel.isEnabled = true
        let view = pageViewController.viewControllers?.first
        if view!.isKind(of: DirectionViewController.self) {
            let directionView = view as! DirectionViewController
            if userDefaults.bool(forKey: ud.key.previousAnnotation.rawValue) {
                directionView.locationManager.startUpdatingLocation()
                directionView.locationManager.startUpdatingHeading()
            }
            if destinationLabel.title(for: .normal) == longPressToSelect {
                destinationLabel.setTitle(selectDestination, for: .normal)
            }else if destinationLabel.title(for: .normal) == activity {
                destinationLabel.setTitle(destinationName, for: .normal)
            }
            presentView = .direction
        }else if view!.isKind(of: MapViewController.self) {
            if destinationLabel.title(for: .normal) == selectDestination {
                destinationLabel.setTitle(longPressToSelect, for: .normal)
            }else if destinationLabel.title(for: .normal) == activity {
                destinationLabel.setTitle(destinationName, for: .normal)
            }
            presentView = .map
        }else if view!.isKind(of: ActivityViewController.self) {
            if destinationLabel.title(for: .normal) == longPressToSelect {
                destinationLabel.setTitle(selectDestination, for: .normal)
            }else if destinationLabel.title(for: .normal) == destinationName {
                showDestinationLabel.text = " "
                destinationLabel.setTitle(activity, for: .normal)
                destinationLabel.isEnabled = false
            }
            presentView = .activity
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        hideObjects(hide: false)
        let viewControllers = contentPageVC.viewControllers
        for view in viewControllers! {
            if view.isKind(of: DirectionViewController.self) {
                let directionView = view as! DirectionViewController
                directionView.distanceLabel.isHidden = false
            }
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
        
        showDestinationLabel.text = NSLocalizedString("destination", comment: "")
        destinationLabel.isEnabled = true
        if destinationLabel.title(for: .normal) == longPressToSelect {
            destinationLabel.setTitle(selectDestination, for: .normal)
        }else if destinationLabel.title(for: .normal) == activity {
            destinationLabel.setTitle(destinationName, for: .normal)
        }
        
        contentPageVC.setViewControllers([getCenter()], direction: direction, animated: true, completion: nil)
    }
    @IBAction func tapActivity() {
        if presentView == .activity {  return  }
        presentView = .activity
        hideObjects(hide: false)
        
        destinationLabel.isEnabled = true
        if destinationLabel.title(for: .normal) == longPressToSelect {
            destinationLabel.setTitle(selectDestination, for: .normal)
        }else if destinationLabel.title(for: .normal) == destinationName {
            showDestinationLabel.text = " "
            destinationLabel.setTitle(activity, for: .normal)
            destinationLabel.isEnabled = false
        }
        
        contentPageVC.setViewControllers([getLeft()], direction: .reverse, animated: true, completion: nil)
    }
    @IBAction func tapMap() {
        if presentView == .map {  return  }
        presentView = .map
        hideObjects(hide: false)
        
        showDestinationLabel.text = NSLocalizedString("destination", comment: "")
        destinationLabel.isEnabled = true
        if destinationLabel.title(for: .normal) == selectDestination {
            destinationLabel.setTitle(longPressToSelect, for: .normal)
        }else if destinationLabel.title(for: .normal) == activity {
            destinationLabel.setTitle(destinationName, for: .normal)
        }
        
        contentPageVC.setViewControllers([getRight()], direction: .forward, animated: true, completion: nil)
    }
    
    @IBAction func tapDestinationLabel() {
        let labelTitle = destinationLabel.title(for: .normal)
        if labelTitle == selectDestination {
            tapMap()
        }else if labelTitle == destinationName {
            if presentView == .direction {
                tapMap()
            }else {
                tapDirection()
            }
        }
    }
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    
    @IBOutlet weak var showDestinationLabel: UILabel!
    @IBOutlet weak var destinationLabel: UIButton!
    @IBOutlet weak var tabStackView: UIStackView!
    
    @IBOutlet weak var containerView: UIView!
    var contentPageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    let hideView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userDefaults.bool(forKey: ud.key.previousAnnotation.rawValue) {
            let latitude: CLLocationDegrees = userDefaults.object(forKey: ud.key.annotationLatitude.rawValue) as! CLLocationDegrees
            let longitude: CLLocationDegrees = userDefaults.object(forKey: ud.key.annotationLongitude.rawValue) as! CLLocationDegrees
            markerLocation = CLLocation(latitude: latitude, longitude: longitude)
            destinationName = userDefaults.string(forKey: ud.key.destinationName.rawValue)
        }
        
        setupViews()
        containerView.addSubview(contentPageVC.view)
        
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        usingTimer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(usingUpdater),
                                          userInfo: nil,
                                          repeats: true)
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
        activityButton.layer.cornerRadius = 25
        activityButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        activityButton.contentMode = UIView.ContentMode.scaleAspectFill
        activityButton.imageEdgeInsets = UIEdgeInsets(top: 0,
                                                      left: 0,
                                                      bottom: 0,
                                                      right: directionButton.bounds.height / 2 / 2)
        mapButton.layer.cornerRadius = 25
        mapButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        mapButton.contentMode = UIView.ContentMode.scaleAspectFill
        mapButton.imageEdgeInsets = UIEdgeInsets(top: 0,
                                                 left: directionButton.bounds.height / 2 / 2,
                                                 bottom: 0,
                                                 right: 0)
        showDestinationLabel.text = NSLocalizedString("destination", comment: "")
        destinationLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        if destinationName != nil {
            destinationLabel.setTitle(destinationName, for: .normal)
        }else {
            destinationLabel.setTitle(selectDestination, for: .normal)
        }
        
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
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)
            ])
        healthStore.requestAuthorization(toShare: nil, read: readTypes as? Set<HKObjectType>, completion: { success, error in
        })
    }
    
    var usingTimer = Timer()
    @objc func usingUpdater() {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let today = dateFormatter.string(from: now)
        var lastUsed: String!
        if let notNil = userDefaults.string(forKey: "lastUsed") {
            lastUsed = notNil
        }else {
            lastUsed = today
            userDefaults.set(today, forKey: "lastUsed")
        }
        var dayChanged = false
        if lastUsed != today {
            print("success!")
            userDefaults.set(0, forKey: ud.key.usingTimes.rawValue)
            userDefaults.set(today, forKey: "lastUsed")
            dayChanged = true
        }
        let correntUsingTime = userDefaults.integer(forKey: ud.key.usingTimes.rawValue)
        userDefaults.set((correntUsingTime + 1), forKey: ud.key.usingTimes.rawValue)
        
        for view in contentPageVC.viewControllers! {
            if view.isKind(of: ActivityViewController.self) {
                let activityView = view as! ActivityViewController
                activityView.getDireWalkUsingTimes()
                if dayChanged {
                    activityView.getWalkingDistance()
                    activityView.getStepCount()
                    activityView.getFlightsClimbed()
                }
            }
        }
    }
    
}
