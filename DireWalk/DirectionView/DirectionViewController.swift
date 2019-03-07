//
//  DirectionViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation

protocol DirectionViewControllerDelegate {
    func hideObjects(hide: Bool)
    func arrivalDestination()
}

class DirectionViewController: UIViewController, CLLocationManagerDelegate {
    
    var delegate: DirectionViewControllerDelegate?
    
    let userDefaults = UserDefaults.standard
    
    var locationManager = CLLocationManager()
    
    var timer = Timer()
    var count = 0.0
    
    @IBOutlet weak var headingImageView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    var destinationLocation = CLLocation()
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationManager.headingFilter = 0.1
        
        let headingRadian: CGFloat = userDefaults.object(forKey: ud.key.directoinButtonHeading.rawValue) as! CGFloat
        headingImageView.transform = CGAffineTransform(rotationAngle: headingRadian * CGFloat.pi / 180)
        let now = Date()
        userDefaults.set(now, forKey: "date")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if destinationLocation.coordinate.latitude == 0.0 ||
            destinationLocation.coordinate.longitude == 0.0 {
            destinationLocation = CLLocation(
                latitude: userDefaults.object(forKey: ud.key.annotationLatitude.rawValue) as! CLLocationDegrees,
                longitude: userDefaults.object(forKey: ud.key.annotationLongitude.rawValue) as! CLLocationDegrees)
        }
        
        let far = destinationLocation.distance(from: locationManager.location!)
        var distance: String!
        var unit: String!
        if 50 > Int(far) {
            distance = "\(Int(far))"
            unit = "m"
        }else if 500 > Int(far){
            distance = "\((Int(far) / 10 + 1) * 10)"
            unit = "m"
        }else {
            let doubleNum = Double(Int(far) / 100 + 1) / 10
            if doubleNum.truncatingRemainder(dividingBy: 1.0) == 0.0 {
                distance = "\(Int(doubleNum))"
                unit = "km"
            }else {
                distance = "\(doubleNum)"
                unit = "km"
            }
        }
        if 30 > Int(far) {
            distanceLabel.isHidden = false
            unitLabel.isHidden = false
            delegate?.arrivalDestination()
        }
        distanceLabel.text = distance
        unitLabel.text = unit
    }
    
    func setupViews() {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        if userDefaults.object(forKey: ud.key.annotationLatitude.rawValue) != nil {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let force = (touch?.force)!/(touch?.maximumPossibleForce)!
        if force == 1.0 {
            if count == 0.0 {
                self.timer = Timer.scheduledTimer(timeInterval: 0.01,
                                                  target: self,
                                                  selector: #selector(self.timeUpdater),
                                                  userInfo: nil,
                                                  repeats: true)
                if distanceLabel.isHidden {
                    distanceLabel.isHidden = false
                    unitLabel.isHidden = false
                    delegate?.hideObjects(hide: false)
                }else {
                    distanceLabel.isHidden = true
                    unitLabel.isHidden = true
                    delegate?.hideObjects(hide: true)
                }
                let generater = UINotificationFeedbackGenerator()
                generater.prepare()
                generater.notificationOccurred(.warning)
            }else if count >= 1.0 {
                timer.invalidate()
                count = 0.0
            }
        }
    }
    
    @objc func timeUpdater() {
        count += 0.01
    }

    @IBAction func longPressWithoutThreeDTouch(_ sender: UILongPressGestureRecognizer) {
        print("呼ばれてるぞう")
        if self.traitCollection.forceTouchCapability != .available {
            if sender.state == UIPanGestureRecognizer.State.began {
                timer = Timer.scheduledTimer(timeInterval: 0.01,
                                             target: self,
                                             selector: #selector(self.timeUpdater),
                                             userInfo: nil,
                                             repeats: true)
            }else if count >= 0.5 && timer.isValid {
                timer.invalidate()
                if distanceLabel.isHidden {
                    distanceLabel.isHidden = false
                    unitLabel.isHidden = false
                    delegate?.hideObjects(hide: false)
                }else {
                    distanceLabel.isHidden = true
                    unitLabel.isHidden = true
                    delegate?.hideObjects(hide: true)
                }
            }
        }
    }
}
