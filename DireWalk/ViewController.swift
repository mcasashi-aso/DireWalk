//
//  ViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import HealthKit
import GoogleMobileAds

class ViewController: UIViewController {
    
    private let viewModel = ViewModel.shared
    private let model = Model.shared
    private let userDefaults = UserDefaults.standard
    
    // these's used DirectionVCDelegate.arrivedDectination()
    var arrivalTimer = Timer()
    var count = 0.0
    
    @IBAction func tapDirection() {
        if viewModel.presentView == .direction { return }
        
        let direction: UIPageViewController.NavigationDirection = (viewModel.presentView == .activity) ? .forward : .reverse
        let directionVC = getDirectionVC() ?? createDirectionVC()
        contentPageVC.setViewControllers([directionVC], direction: direction, animated: true)
        viewModel.state = .direction
        updateLabels()
    }
    @IBAction func tapActivity() {
        if viewModel.presentView == .activity { return }
        let activityVC = getActivityVC() ?? createActivityVC()
        contentPageVC.setViewControllers([activityVC], direction: .reverse, animated: true)
        viewModel.state = .activity
        updateLabels()
    }
    @IBAction func tapMap() {
        if viewModel.presentView == .map { return }
        let mapVC = getMapVC() ?? createMapVC()
        contentPageVC.setViewControllers([mapVC], direction: .forward, animated: true)
        viewModel.state = .map
        updateLabels()
    }
    @IBAction func tapDestinationLabel() {
        if model.place == nil || viewModel.presentView == .direction {
            tapMap()
        }else { tapDirection() }
        updateLabels()
    }
    
    func updateLabels() {
        destinationLabel.setTitle(viewModel.labelTitle, for: .normal)
        aboutLabel.text = viewModel.aboutLabelText
    }
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var destinationLabel: UIButton!
    @IBOutlet weak var tabStackView: UIStackView!
    
    @IBOutlet weak var containerView: UIView!
    var contentPageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        model.delegate = self
        
        setupViews()
        containerView.addSubview(contentPageVC.view)
        
        usingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(usingUpdater), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { UIStatusBarStyle.lightContent }
    var iosControllersHidden = false
    override var prefersStatusBarHidden: Bool { iosControllersHidden }
    override var prefersHomeIndicatorAutoHidden: Bool { iosControllersHidden }
    
    private func setupViews(){
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
        
        activityButton.contentMode = UIView.ContentMode.scaleAspectFill
        activityButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                                                      right: directionButton.bounds.height / 2 / 2)
        mapButton.contentMode = UIView.ContentMode.scaleAspectFill
        mapButton.imageEdgeInsets = UIEdgeInsets(top: 0,
                                                 left: directionButton.bounds.height / 2 / 2,
                                                 bottom: 0, right: 0)
        aboutLabel.text = NSLocalizedString("destination", comment: "")
        destinationLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        addChild(contentPageVC)
        contentPageVC.view.frame = containerView.bounds
        contentPageVC.delegate = viewModel
        contentPageVC.dataSource = self
        contentPageVC.didMove(toParent: self)
        contentPageVC.setViewControllers([createDirectionVC()], direction: .forward, animated: true, completion: nil)
    }
    
    var usingTimer = Timer()
    @objc func usingUpdater() {
        let now = Date()
        // TODO: DaeFormatterはたくさん作らない方が良い
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let today = dateFormatter.string(from: now)
        var lastUsed: String!
        if let hoge = userDefaults.get(.lastUsed) {
            lastUsed = hoge
        }else {
            lastUsed = today
            userDefaults.set(today, forKey: .lastUsed)
        }
        var dayChanged = false
        if lastUsed != today {
            userDefaults.set(0, forKey: .usingTimes)
            userDefaults.set(today, forKey: .lastUsed)
            dayChanged = true
        }
        guard let correntUsingTime = userDefaults.get(.usingTimes) else { return }
        userDefaults.set((correntUsingTime + 1), forKey: .usingTimes)
        
        if ceil(Double(correntUsingTime) / 60.0) !=
            ceil(Double(correntUsingTime + 1) / 60.0) {
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
}

// MARK: Get View Controller
extension ViewController: UIPageViewControllerDataSource {
    func getDirectionVC() -> DirectionViewController? {
        guard let viewControllers = contentPageVC.viewControllers else { return nil }
        for vc in viewControllers {
            if let directionVC = vc as? DirectionViewController {
                return directionVC
            }
        }
        return nil
    }
    func getMapVC() -> MapViewController? {
        guard let viewControllers = contentPageVC.viewControllers else { return nil }
        for vc in viewControllers {
            if let mapVC = vc as? MapViewController {
                return mapVC
            }
        }
        return nil
    }
    func getActivityVC() -> ActivityViewController? {
        guard let viewControllers = contentPageVC.viewControllers else { return nil }
        for vc in viewControllers {
            if let activityVC = vc as? ActivityViewController {
                return activityVC
            }
        }
        return nil
    }
    
    func createDirectionVC() -> DirectionViewController{
        let sb = UIStoryboard(name: "Direction", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! DirectionViewController
        return vc
    }
    func createMapVC() -> MapViewController{
        let sb = UIStoryboard(name: "Map", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! MapViewController
        return vc
    }
    func createActivityVC() -> ActivityViewController{
        let sb = UIStoryboard(name: "Activity", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! ActivityViewController
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is ActivityViewController:  return nil
        case is DirectionViewController: return getActivityVC() ?? createActivityVC()
        case is MapViewController:       return getDirectionVC() ?? createDirectionVC()
        default: return nil
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is MapViewController:       return nil
        case is DirectionViewController: return getMapVC() ?? createMapVC()
        case is ActivityViewController:  return getDirectionVC() ?? createDirectionVC()
        default: return nil
        }
     }
}

// MARK: ModelDelegate
extension ViewController: ModelDelegate {
    
    func didChangePlace() {
        updateLabels()
        if let mapVC = getMapVC() {
            mapVC.addMarker(new: true)
        }
        if let directionVC = getDirectionVC() {
            directionVC.updateFar()
        }
    }
    
    func didChangeFar() {
        if let directionVC = getDirectionVC() {
            directionVC.updateFar()
        }
    }
    
    func didChangeHeading() {
        if let directionVC = getDirectionVC() {
            directionVC.updateHeadingImage()
        }
        if let mapVC = getMapVC() {
            mapVC.updateHeadingImageView()
        }
        let affineTransform = CGAffineTransform(rotationAngle: viewModel.buttonAngle)
        directionButton.transform = affineTransform
    }
    
    func addHeadingView(to annotationView: MKAnnotationView) {
        guard let mapVC = getMapVC() else { return }
        mapVC.addHeadingView(to: annotationView)
    }
    
    func askAllowHealthKit() {
        let readTypes = Set([
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)
        ])
        HKHealthStore().requestAuthorization(toShare: nil, read: readTypes as? Set<HKObjectType>, completion: { success, error in
        })
    }
    
    func showRequestAccessLocation() {
        let sb = UIStoryboard(name: "RequestLocation", bundle: nil)
        let view = sb.instantiateInitialViewController()
        self.present(view!, animated: true, completion: nil)
    }
}


// MARK: ViewModelDelegate
extension ViewController: ViewModelDelegate {
    func hideControllers(_ isHidden: Bool) {
        <#code#>
    }
    
    func didChangeSearchTableViewElements() {
        
    }
}
