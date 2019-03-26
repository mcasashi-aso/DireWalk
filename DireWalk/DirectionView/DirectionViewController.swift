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
    
    @IBOutlet weak var headingImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var destinationLocation = CLLocation()
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationManager.headingFilter = 0.1
        
        let headingRadian: CGFloat = userDefaults.object(forKey: udKey.directoinButtonHeading.rawValue) as! CGFloat
        headingImageView.transform = CGAffineTransform(rotationAngle: headingRadian * CGFloat.pi / 180)
    }
    
    func getDestinationLocation() {
        destinationLocation = CLLocation(
                latitude: userDefaults.object(forKey: udKey.annotationLatitude.rawValue) as! CLLocationDegrees,
                longitude: userDefaults.object(forKey: udKey.annotationLongitude.rawValue) as! CLLocationDegrees)
    }
    
    
    
    func updateFar() {
        if destinationLocation.coordinate.latitude == 0.0 &&
            destinationLocation.coordinate.longitude == 0.0 {
            let distanceText = NSAttributedString(
                string: NSLocalizedString("swipe", comment: ""),
                attributes: [.foregroundColor : UIColor.white,
                             .font : UIFont.systemFont(ofSize: 40)])
            distanceLabel.attributedText = distanceText
            return
        }
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
        getDestinationLocation()
        updateFar()
    }
    
    func setupViews() {
        headingImageView.image = UIImage(named: "Direction")?.withRenderingMode(.alwaysTemplate)
        distanceLabel.adjustsFontSizeToFitWidth = true
        headingImageView.transform = CGAffineTransform(rotationAngle: 90 * CGFloat.pi / 180)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        locationManager.delegate = self
        if userDefaults.bool(forKey: udKey.showFar.rawValue) {
            if distanceLabel.text != NSLocalizedString("swipe", comment: "") {
                distanceLabel.isHidden = true
            }
        }else {
            distanceLabel.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        headingImageView.tintColor = UIColor(white: CGFloat(userDefaults.float(forKey: udKey.arrowColorWhite.rawValue)), alpha: 1)
        
        if userDefaults.bool(forKey: udKey.showFar.rawValue) {
            if distanceLabel.text != NSLocalizedString("swipe", comment: "") {
                distanceLabel.isHidden = true
            }
        }else {
            distanceLabel.isHidden = false
        }
        if  userDefaults.bool(forKey: udKey.previousAnnotation.rawValue) {
            getDestinationLocation()
        }
        updateFar()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            if userDefaults.bool(forKey: udKey.previousAnnotation.rawValue) {
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
            }
        default:
            break
        }
    }
    
    
    var isHidden = false
    
    var timer = Timer()
    var count = 0.0
    @objc func timeUpdater() {
        count += 0.01
        
        if self.traitCollection.forceTouchCapability == .unavailable {
            if count >= 0.5 && timer.isValid {
                timer.invalidate()
                checkHidden()
                count = 0.0
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("began")
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let force = (touch?.force)!/(touch?.maximumPossibleForce)!
        print(force)
        if force == 1.0 {
            if !timer.isValid{
                self.timer = Timer.scheduledTimer(timeInterval: 0.01,
                                                  target: self,
                                                  selector: #selector(self.timeUpdater),
                                                  userInfo: nil,
                                                  repeats: true)
                checkHidden()
            }else if count >= 1.0 {
                timer.invalidate()
                count = 0.0
            }
        }
    }
    @IBAction func longPressWithoutThreeDTouch(_ sender: UILongPressGestureRecognizer) {
        if self.traitCollection.forceTouchCapability == .available { return }
        if sender.state == UIPanGestureRecognizer.State.began {
            timer = Timer.scheduledTimer(timeInterval: 0.01,
                                            target: self,
                                            selector: #selector(self.timeUpdater),
                                            userInfo: nil,
                                            repeats: true)
        }
    }
    
    func checkHidden() {
        if isHidden {
            if !userDefaults.bool(forKey: udKey.showFar.rawValue) {
                distanceLabel.isHidden = false
            }
            delegate?.hideObjects(hide: false)
            isHidden = false
        }else {
            distanceLabel.isHidden = true
            delegate?.hideObjects(hide: true)
            isHidden = true
        }
        hideAlart()
        let generater = UINotificationFeedbackGenerator()
        generater.prepare()
        generater.notificationOccurred(.warning)
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
}
