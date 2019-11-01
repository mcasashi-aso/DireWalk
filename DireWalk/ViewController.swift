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

final class ViewController: UIViewController, UIPageViewControllerDataSource, ViewModelDelegate, SettingsViewControllerDelegate, EditFavoriteViewControllerDelegate, GADBannerViewDelegate {
    
    // MARK: - Model
    private let viewModel = ViewModel.shared
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Controller Button Action
    @IBAction func tapDirection() {
        if viewModel.presentView == .direction { return }
        let direction: UIPageViewController.NavigationDirection
        direction = (viewModel.presentView == .activity) ? .forward : .reverse
        let directionVC = getVC(DirectionViewController.self) ?? DirectionViewController.create()
        contentPageVC.setViewControllers([directionVC], direction: direction, animated: true)
        viewModel.state = .direction
    }
    @IBAction func tapActivity() {
        if viewModel.presentView == .activity { return }
        let activityVC = getVC(ActivityViewController.self) ?? ActivityViewController.create()
        contentPageVC.setViewControllers([activityVC], direction: .reverse, animated: true)
        viewModel.state = .activity
    }
    @IBAction func tapMap() {
        if viewModel.presentView == .map {
            viewModel.state = (viewModel.state == .search) ? .map : .search
            if (viewModel.state == .search) && (viewModel.searchTableViewPlaces.isEmpty) {
                getVC(MapViewController.self)?.searchBar.becomeFirstResponder()
            }
        }else {
            let mapVC = getVC(MapViewController.self) ?? MapViewController.create()
            contentPageVC.setViewControllers([mapVC], direction: .forward, animated: true)
            viewModel.state = .map
        }
    }
    
    // MARK: - Views
    @IBOutlet weak var directionButton: UIButton! {
        didSet {
            directionButton.imageView?.sizeThatFits(CGSize(
                width: Double(directionButton.bounds.width) * 2.0.squareRoot(),
                height: Double(directionButton.bounds.height) * 2.0.squareRoot()))
            
            directionButton.layer.cornerRadius = directionButton.bounds.height / 2
            directionButton.layer.masksToBounds = true
            directionButton.layer.shadowOffset = CGSize(width: 1, height: 1)
            directionButton.layer.shadowRadius = 4
            directionButton.layer.shadowOpacity = 0.5
            directionButton.accessibilityLabel = "Direction"
        }
    }
    @IBOutlet weak var mapButton: UIButton! {
        didSet {
            mapButton.contentMode = UIView.ContentMode.scaleAspectFill
            mapButton.accessibilityLabel = "Map"
        }
    }
    @IBOutlet weak var activityButton: UIButton! {
        didSet {
            activityButton.contentMode = UIView.ContentMode.scaleAspectFill
            activityButton.accessibilityLabel = "Activity"
        }
    }
    
    // UIButtonだけど押せないので名前はLabelに
    @IBOutlet weak var aboutLabel: UIButton! {
        didSet { aboutLabel.titleLabel?.adjustsFontSizeToFitWidth = true }
    }
    @IBOutlet weak var destinationLabel: UIButton! {
        didSet {
            destinationLabel.titleLabel?.adjustsFontSizeToFitWidth = true
            destinationLabel.accessibilityLabel = "Destination"
        }
    }
    
    @IBOutlet weak var tabStackView: UIStackView!
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var statusBarBackgroundView: UIView!
    @IBOutlet weak var homeIndicatorBackgroundView: UIView!
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            contentPageVC = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: .horizontal)
            contentPageVC.view.frame = containerView.bounds
            contentPageVC.delegate = viewModel
            contentPageVC.dataSource = self
            contentPageVC.didMove(toParent: self)
            contentPageVC.setViewControllers([DirectionViewController.create()],
                                             direction: .forward, animated: true)
            containerView.addSubview(contentPageVC.view)
        }
    }
    var contentPageVC: UIPageViewController!
    
    @IBOutlet weak var bannerView: GADBannerView! {
        didSet{
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
            bannerView.adUnitID = "ca-app-pub-7482106968377175/7907556553"
            bannerView.rootViewController = self
            let request = GADRequest()
            request.testDevices = ["16bf9f6807aafaa19ee8b65b15618e2e"]
            bannerView.load(request)
        }
    }
    
    // MARK: - View's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageInsets = directionButton.bounds.height / 4
        activityButton.imageEdgeInsets.right = imageInsets
        mapButton.imageEdgeInsets.left = imageInsets
        
        updateViews()
        
        viewModel.delegate = self
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(showRequestAccessLocation),
            name: .showRequestAccessLocation, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        aboutLabel.setTitle(viewModel.aboutLabelText, for: .normal)
        destinationLabel.setTitle(viewModel.labelTitle, for: .normal)
        contentPageVC.viewControllers?.forEach { $0.view.layoutIfNeeded() }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "settings":
            let navigationController = segue.destination as! UINavigationController
            let settingsVC = navigationController.topViewController as! SettingsViewController
            settingsVC.delegate = self
        default: break
        }
    }

    // MARK: - UIPageViewControllerDataSource
    func getVC<VC: UIViewController>(_ type: VC.Type) -> VC? {
        guard let viewControllers = contentPageVC.viewControllers else { return nil }
        return viewControllers.compactMap { $0 as? VC }.first
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is ActivityViewController: return nil
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
        case is MapViewController: return nil
        case is DirectionViewController:
            return getVC(MapViewController.self) ?? MapViewController.create()
        case is ActivityViewController:
            return getVC(DirectionViewController.self) ?? DirectionViewController.create()
        default: return nil
        }
    }
    
    // MARK: - ViewModelDelegate
    func didChangeState() {
        hideControllers(viewModel.state == .hideControllers)
        getVC(MapViewController.self)?.applyViewConstraints()
        destinationLabel.setTitle(viewModel.labelTitle, for: .normal)
        aboutLabel.setTitle(viewModel.aboutLabelText, for: .normal)
    }
    
    func didChangePlace() {
        destinationLabel.setTitle(viewModel.labelTitle, for: .normal)
        getVC(MapViewController.self)?.addMarker(new: true)
        updateViews()
    }
    
    func updateViews() {
        getVC(DirectionViewController.self)?.updateFarLabel()
        getVC(DirectionViewController.self)?.updateHeadingImage()
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .allowAnimatedContent], animations: {
            let transform = CGAffineTransform(rotationAngle: self.viewModel.headingImageAngle)
            self.directionButton.transform = transform
        }, completion: nil)
    }
    
    func presentEditPlaceView(place: Place) {
        let navigationController = EditFavoriteViewController.create(place)
        let vc = navigationController.topViewController as! EditFavoriteViewController
        vc.delegate = self
        present(navigationController, animated: true, completion: nil)
    }
    
    func reloadTableViewData(new: [Place], old: [Place]) {
        getVC(MapViewController.self)?.reloadTableView(new: new, old: old)
    }
    
    func moveCenterToPlace() {
        getVC(MapViewController.self)?.moveCenterToPlace()
    }
    
    func updateActivityViewData(dayChanged: Bool) {
        let activityView = getVC(ActivityViewController.self)
        activityView?.updateDireWalkUsingTimes()
        if dayChanged {
            activityView?.updateWalkingDistance()
            activityView?.updateFlightsClimbed()
            activityView?.updateStepCount()
        }
    }

    // MARK: - UserRequest
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
    
    @objc func showRequestAccessLocation() {
        let sb = UIStoryboard(name: "RequestLocation", bundle: nil)
        let view = sb.instantiateInitialViewController()
        view?.modalPresentationStyle = .fullScreen
        self.present(view!, animated: true, completion: nil)
    }

    // MARK: - Hide Controllers
    func hideControllers(_ isHidden: Bool) {
        statusBarBackgroundView.isHidden = isHidden
        titleBar.isHidden = isHidden
        directionButton.isHidden = isHidden
        tabStackView.isHidden = isHidden
        homeIndicatorBackgroundView.isHidden = isHidden
        bannerView.isHidden = isHidden
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        getVC(DirectionViewController.self)?.updateFarLabel()
        if isHidden {
            noticeControllersHidden()
        }
    }
    
    // status bar & home indicator
    override var preferredStatusBarStyle: UIStatusBarStyle { UIStatusBarStyle.lightContent }
    override var prefersStatusBarHidden: Bool { viewModel.state == .hideControllers }
    override var prefersHomeIndicatorAutoHidden: Bool { viewModel.state == .hideControllers }
    
    func noticeControllersHidden() {
        showHideAlart()
        let generater = UINotificationFeedbackGenerator()
        generater.prepare()
        generater.notificationOccurred(.warning)
    }
    
    func showHideAlart() {
        userDefaults.register(defaults: ["hideAlert" : true])
        if userDefaults.bool(forKey: "hideAlert") {
            let alert = UIAlertController(title: "arrowOnlyMode".localized,
                                          message: "arrowOnlyModeCaption".localized,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            userDefaults.set(false, forKey: "hideAlert")
            present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Settings Delegate
    func settingsViewController(didChange settingsViewController: SettingsViewController) {
        getVC(DirectionViewController.self)?.applyToSettings()
    }
    
    func settingsViewController(didFinish settingsViewController: SettingsViewController) {
        getVC(DirectionViewController.self)?.applyToSettings()
        dismiss(animated: true)
    }
    
    // MARK: - Edit Delegate
    func editFavoriteViewControllerDidFinish() {
        
        dismiss(animated: true)
    }
}

