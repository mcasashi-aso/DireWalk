//
//  ReauestLocationViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/10.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation

// TODO: 直す気を起こすところから始めよう
class RequestLocationViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var toSettingsButton: UIButton!
    @IBOutlet weak var stringsTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var walkThroughScrollView: UIScrollView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        toSettingsButton.setTitle(NSLocalizedString("toSettings", comment: ""), for: .normal)
        stringsTextView.text = NSLocalizedString("reauestLocation", comment: "")
        titleLabel.text = NSLocalizedString("pleaseAllowLocation", comment: "")
        
        toSettingsButton.layer.cornerRadius = 13
        toSettingsButton.layer.masksToBounds = true
        titleLabel.adjustsFontSizeToFitWidth = true
        
        locationManager.delegate = self
        
        walkThroughScrollView.delegate = self
        nextButton.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
        backButton.setTitle(NSLocalizedString("back", comment: ""), for: .normal)
        nextButton.layer.cornerRadius = 22
        nextButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        backButton.layer.cornerRadius = 22
        backButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        changeButtonEnabled()
    }
    
    @IBAction func toSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            self.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    let screenWidth = UIScreen.main.bounds.width
    @IBAction func tapNext() {
        changeContentViewOfWalkThroughView(next: true)
    }
    @IBAction func tapBack() {
        changeContentViewOfWalkThroughView(next: false)
    }
    func changeContentViewOfWalkThroughView(next: Bool) {
        let svX = walkThroughScrollView.contentOffset.x
        var viewNumber: CGFloat = 0
        if svX < screenWidth * 0 {
            viewNumber = 0
        }else if svX < screenWidth * 1 {
            viewNumber = next ? 1 : 0
        }else if svX < screenWidth * 2 {
            viewNumber = next ? 2 : 0
        }else if svX < screenWidth * 3 {
            viewNumber = next ? 3 : 1
        }else if svX < screenWidth * 4 {
            viewNumber = next ? 4 : 2
        }else if svX < screenWidth * 5 {
            viewNumber = next ? 5 : 3
        }else {
            viewNumber = next ? 5 : 4
        }
        setWalkThroughViewContentOffset(x: screenWidth * viewNumber)
        changeButtonEnabled()
    }
    func setWalkThroughViewContentOffset(x: CGFloat) {
        walkThroughScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        changeButtonEnabled()
    }
    
    func changeButtonEnabled() {
        let svX = walkThroughScrollView.contentOffset.x
        if svX < 1 {
            buttonEnabled(button: backButton, isEnabled: false)
            buttonEnabled(button: nextButton, isEnabled: true)
        }else if svX >= screenWidth * 5 {
            buttonEnabled(button: backButton, isEnabled: true)
            buttonEnabled(button: nextButton, isEnabled: false)
        }else {
            buttonEnabled(button: backButton, isEnabled: true)
            buttonEnabled(button: nextButton, isEnabled: true)
        }
    }
    func buttonEnabled(button: UIButton, isEnabled: Bool) {
        if isEnabled {
            button.isEnabled = true
            button.backgroundColor = .mySkyBlue
        }else {
            button.isEnabled = false
            button.backgroundColor = .gray
        }
    }
    
}
