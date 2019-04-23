//
//  ReauestLocationViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/10.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation

class RequestLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var toSettingsButton: UIButton!
    @IBOutlet weak var stringsTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        toSettingsButton.setTitle(NSLocalizedString("toSettings", comment: ""), for: .normal)
        stringsTextView.text = NSLocalizedString("reauestLocation", comment: "")
        titleLabel.text = NSLocalizedString("pleaseAllowLocation", comment: "")
        
        toSettingsButton.layer.cornerRadius = 8
        toSettingsButton.layer.masksToBounds = true
        titleLabel.adjustsFontSizeToFitWidth = true
        
        locationManager.delegate = self
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

}
