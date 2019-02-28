//
//  ViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    let healthStore = HKHealthStore()
    
    enum present: String {
        case direction
        case activity
        case map
    }
    var presentView: present = .direction
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: ActivityViewController.self) {
            print("before, \(presentView.rawValue)")
            return nil
        }else if viewController.isKind(of: DirectionViewController.self) {
            presentView = .activity
            print("before, \(presentView.rawValue)")
            return getLeft()
        }else if viewController.isKind(of: MapViewController.self) {
            presentView = .direction
            print("before, \(presentView.rawValue)")
            return getCenter()
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: MapViewController.self) {
            print("after, \(presentView.rawValue)")
            return nil
        }else if viewController.isKind(of: DirectionViewController.self) {
            print("after, \(presentView.rawValue)")
            presentView = .map
            return getRight()
        }else if viewController.isKind(of: ActivityViewController.self) {
            print("after, \(presentView.rawValue)")
            presentView = .direction
            return getCenter()
        }
        return nil
     }
    
    func getCenter() -> DirectionViewController{
        let sb = UIStoryboard(name: "Direction", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! DirectionViewController
        return vc
    }
    func getRight() -> MapViewController{
        let sb = UIStoryboard(name: "Map", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! MapViewController
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
