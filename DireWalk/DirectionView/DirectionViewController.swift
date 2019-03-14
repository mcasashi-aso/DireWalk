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
    
    var destinationLocation = CLLocation()
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationManager.headingFilter = 0.1
        
        let headingRadian: CGFloat = userDefaults.object(forKey: ud.key.directoinButtonHeading.rawValue) as! CGFloat
        headingImageView.transform = CGAffineTransform(rotationAngle: headingRadian * CGFloat.pi / 180)
    }
    
    func getDestinationLocation() {
        if destinationLocation.coordinate.latitude == 0.0 ||
            destinationLocation.coordinate.longitude == 0.0 {
            destinationLocation = CLLocation(
                latitude: userDefaults.object(forKey: ud.key.annotationLatitude.rawValue) as! CLLocationDegrees,
                longitude: userDefaults.object(forKey: ud.key.annotationLongitude.rawValue) as! CLLocationDegrees)
        }
    }
    
    
    
    func updateFar() {
        let far = destinationLocation.distance(from: locationManager.location!)
        var distance: String = ""
        var unit: String = ""
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
            delegate?.arrivalDestination()
        }
        let distanceAttributed: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 80),
            .foregroundColor : UIColor.white
        ]
        let unitAttributed: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 40),
            .foregroundColor : UIColor.white
        ]
        let attributedSpace = NSAttributedString(string: "   ", attributes: unitAttributed)
        let attributedDistance = NSAttributedString(string: distance, attributes: distanceAttributed)
        let attributedUnit = NSAttributedString(string: " " + unit, attributes: unitAttributed)
        let labelText = NSMutableAttributedString()
        labelText.append(attributedSpace)
        labelText.append(attributedDistance)
        labelText.append(attributedUnit)
        distanceLabel.attributedText = labelText
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateFar()
    }
    
    func setupViews() {
        let distanceText = NSAttributedString(
            string: NSLocalizedString("swipe", comment: ""),
            attributes: [.foregroundColor : UIColor.white,
                         .font : UIFont.systemFont(ofSize: 40)])
        distanceLabel.attributedText = distanceText
        distanceLabel.adjustsFontSizeToFitWidth = true
        headingImageView.transform = CGAffineTransform(rotationAngle: 90 * CGFloat.pi / 180)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        locationManager.delegate = self
        userDefaults.addObserver(self, forKeyPath: ud.key.annotationLatitude.rawValue, options: [NSKeyValueObservingOptions.new], context: nil)
        userDefaults.addObserver(self, forKeyPath: ud.key.annotationLongitude.rawValue, options: [NSKeyValueObservingOptions.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        getDestinationLocation()
        updateFar()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            if userDefaults.bool(forKey: ud.key.previousAnnotation.rawValue) {
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
            }
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let force = (touch?.force)!/(touch?.maximumPossibleForce)!
        if force == 1.0 {
            if !timer.isValid{
                self.timer = Timer.scheduledTimer(timeInterval: 0.001,
                                                  target: self,
                                                  selector: #selector(self.timeUpdater),
                                                  userInfo: nil,
                                                  repeats: true)
                if distanceLabel.isHidden {
                    distanceLabel.isHidden = false
                    delegate?.hideObjects(hide: false)
                }else {
                    distanceLabel.isHidden = true
                    delegate?.hideObjects(hide: true)
                    hideAlart()
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
        count += 0.001
    }
    
    func hideAlart() {
        userDefaults.register(defaults: ["hideAlert" : true])
        if userDefaults.bool(forKey: "hideAlert") {
            let alert = UIAlertController(title: NSLocalizedString("directionOnlyMode", comment: ""),
                message: NSLocalizedString("directionOnlyModeCaption", comment: ""),
                preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) -> Void in })
            alert.addAction(okAction)
            userDefaults.set(false, forKey: "hideAlert")
            present(alert, animated: true, completion: nil)
        }
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
                    delegate?.hideObjects(hide: false)
                }else {
                    distanceLabel.isHidden = true
                    delegate?.hideObjects(hide: true)
                }
            }
        }
    }
}
