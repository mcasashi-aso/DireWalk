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
    
    @IBAction func tapDirection() {
        if viewModel.presentView == .direction { return }
        
        let direction: UIPageViewController.NavigationDirection
        direction = (viewModel.presentView == .activity) ? .forward : .reverse
        let directionVC = getVC(DirectionViewController.self) ?? DirectionViewController.create()
        contentPageVC.setViewControllers([directionVC], direction: direction, animated: true)
        viewModel.state = .direction
        updateLabels()
    }
    @IBAction func tapActivity() {
        if viewModel.presentView == .activity { return }
        let activityVC = getVC(ActivityViewController.self) ?? ActivityViewController.create()
        contentPageVC.setViewControllers([activityVC], direction: .reverse, animated: true)
        viewModel.state = .activity
        updateLabels()
    }
    @IBAction func tapMap() {
        if viewModel.presentView == .map { return }
        let mapVC = getVC(MapViewController.self) ?? MapViewController.create()
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
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var destinationLabel: UIButton!
    
    @IBOutlet weak var tabStackView: UIStackView!
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var statusBarBackgroundView: UIView!
    @IBOutlet weak var homeIndicatorBackgroundView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    var contentPageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    @IBOutlet weak var bannerView: GADBannerView! {
        didSet{
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        model.delegate = self
        
        setupViews()
        setupAds()
        containerView.addSubview(contentPageVC.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { UIStatusBarStyle.lightContent }
    override var prefersStatusBarHidden: Bool { viewModel.state == .hideControllers }
    override var prefersHomeIndicatorAutoHidden: Bool { viewModel.state == .hideControllers }
    
    private func setupViews() {
        directionButton.imageView?.sizeThatFits(CGSize(
            width: Double(directionButton.bounds.width) * 2.0.squareRoot(),
            height: Double(directionButton.bounds.height) * 2.0.squareRoot()))
        
        directionButton.layer.cornerRadius = directionButton.bounds.height / 2
        directionButton.layer.masksToBounds = true
        directionButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        directionButton.layer.shadowRadius = 4
        directionButton.layer.shadowOpacity = 0.5
        
        activityButton.contentMode = UIView.ContentMode.scaleAspectFill
        activityButton.imageEdgeInsets.right = directionButton.bounds.height / 2 / 2
        mapButton.contentMode = UIView.ContentMode.scaleAspectFill
        mapButton.imageEdgeInsets.left = directionButton.bounds.height / 2 / 2
        aboutLabel.text = "destination".localized
        destinationLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        addChild(contentPageVC)
        contentPageVC.view.frame = containerView.bounds
        contentPageVC.delegate = viewModel
        contentPageVC.dataSource = self
        contentPageVC.didMove(toParent: self)
        contentPageVC.setViewControllers([DirectionViewController.create()],
                                         direction: .forward, animated: true)
    }
}

// MARK: UIPageViewControllerDataSource
extension ViewController: UIPageViewControllerDataSource {
    
    func getVC<VC: UIViewController>(_ type: VC.Type) -> VC? {
        guard let viewControllers = contentPageVC.viewControllers else { return nil }
        for vc in viewControllers {
            if let result = vc as? VC {
                return result
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is ActivityViewController:  return nil
        case is DirectionViewController:
            return getVC(ActivityViewController.self) ?? ActivityViewController.create()
        case is MapViewController:
            return getVC(DirectionViewController.self) ?? DirectionViewController.create()
        default: return nil
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is MapViewController:       return nil
        case is DirectionViewController:
            return getVC(MapViewController.self) ?? MapViewController.create()
        case is ActivityViewController:
            return getVC(DirectionViewController.self) ?? DirectionViewController.create()
        default: return nil
        }
     }
}

// MARK: ModelDelegate
extension ViewController: ModelDelegate {
    
    func didChangePlace() {
        updateLabels()
        if let mapVC = getVC(MapViewController.self) {
            mapVC.addMarker(new: true)
        }
        if let directionVC = getVC(DirectionViewController.self) {
            directionVC.updateFarLabel()
        }
    }
    
    func didChangeFar() {
        if let directionVC = getVC(DirectionViewController.self) {
            directionVC.updateFarLabel()
        }
    }
    
    func didChangeHeading() {
        if let directionVC = getVC(DirectionViewController.self) {
            directionVC.updateHeadingImage()
        }
        if let mapVC = getVC(MapViewController.self) {
            mapVC.updateHeadingImageView()
        }
        let affineTransform = CGAffineTransform(rotationAngle: viewModel.buttonAngle)
        directionButton.transform = affineTransform
    }
    
    func addHeadingView(to annotationView: MKAnnotationView) {
        guard let mapVC = getVC(MapViewController.self) else { return }
        mapVC.addHeadingView(to: annotationView)
    }
    
    func askAllowHealthKit() {
        let readTypes = Set([
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)
        ])
        guard let read = readTypes as? Set<HKObjectType> else { return }
        HKHealthStore().requestAuthorization(toShare: nil, read: read) { success, error in
        }
    }
    
    func showRequestAccessLocation() {
        let sb = UIStoryboard(name: "RequestLocation", bundle: nil)
        let view = sb.instantiateInitialViewController()
        self.present(view!, animated: true, completion: nil)
    }
}


// MARK: ViewModelDelegate
extension ViewController: ViewModelDelegate {
    
    func updateLabels() {
        destinationLabel.setTitle(viewModel.labelTitle, for: .normal)
        aboutLabel.text = viewModel.aboutLabelText
    }
    
    func didChangeSearchTableViewElements() {
        if let mapVC = getVC(MapViewController.self) {
            mapVC.tableView.reloadData()
        }
    }
    
    func didChangeState() {
        hideControllers(viewModel.state == .hideControllers)
        if let mapVC = getVC(MapViewController.self) {
            mapVC.applyViewConstraints()
            mapVC.tableView.reloadData()
        }
    }
    
    func SearchedTableViewCellSelected() {
        if let mapVC = getVC(MapViewController.self) {
            mapVC.searchedTableViewCellSelected()
        }
    }
    
    func updateActivityViewData(dayChanged: Bool) {
        if let activityView = getVC(ActivityViewController.self) {
            activityView.getDireWalkUsingTimes()
            if dayChanged {
                activityView.getWalkingDistance()
                activityView.getFlightsClimbed()
                activityView.getStepCount()
            }
        }
    }
}

// MARK: Hide Controllers
extension ViewController {
    func hideControllers(_ isHidden: Bool) {
        if isHidden { noticeControllersHidden() }
        statusBarBackgroundView.isHidden = isHidden
        titleBar.isHidden = isHidden
        directionButton.isHidden = isHidden
        tabStackView.isHidden = isHidden
        homeIndicatorBackgroundView.isHidden = isHidden
        bannerView.isHidden = isHidden
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        getVC(DirectionViewController.self)?.updateFarLabel()
    }
    func noticeControllersHidden() {
        showHideAlart()
        let generater = UINotificationFeedbackGenerator()
        generater.prepare()
        generater.notificationOccurred(.warning)
    }
    func showHideAlart() {
        userDefaults.register(defaults: ["hideAlert" : true])
        if userDefaults.bool(forKey: "hideAlert") {
            let alert = UIAlertController(title: "directionOnlyMode".localized,
                                          message: "directionOnlyModeCaption".localized,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            userDefaults.set(false, forKey: "hideAlert")
            present(alert, animated: true, completion: nil)
        }
    }
}


// MARK: GADBannerViewDelegate
extension ViewController: GADBannerViewDelegate {
    func setupAds() {
        bannerView.adUnitID = "ca-app-pub-7482106968377175/7907556553"
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["08414f421dd5519a221bf0414a3ec95e"]
        bannerView.load(request)
    }
}
