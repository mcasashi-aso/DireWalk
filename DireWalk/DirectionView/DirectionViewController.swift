//
//  DirectionViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation

class DirectionViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    let viewModel = ViewModel.shared
    let model = Model.shared
    
    @IBOutlet weak var headingImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func updateFar() {
        distanceLabel.attributedText = viewModel.farLabelText
    }
    
    func updateHeadingImage() {
        headingImageView.transform = CGAffineTransform(rotationAngle: viewModel.headingImageAngle)
    }
    
    private func setupViews() {
        headingImageView.image = UIImage(named: "Direction")!.withRenderingMode(.alwaysTemplate)
        distanceLabel.adjustsFontSizeToFitWidth = true
        let whiteValue = viewModel.arrowColor
        headingImageView.tintColor = UIColor(white: whiteValue, alpha: 1)
        updateFar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    var isHidden = false
    
    var timer = Timer()
    var count = 0.0
    @objc func timeUpdater() {
        count += 0.01
        
        if self.traitCollection.forceTouchCapability == .unavailable {
            if count >= 0.5 && timer.isValid {
                timer.invalidate()
                taptic()
                count = 0.0
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let force = touch?.force,
            let maximum = touch?.maximumPossibleForce else { return }
        let percent = force / maximum
        if percent == 1.0 {
            if !timer.isValid{
                self.timer = Timer.scheduledTimer(timeInterval: 0.01,
                                                  target: self,
                                                  selector: #selector(self.timeUpdater),
                                                  userInfo: nil,
                                                  repeats: true)
                taptic()
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
    
    func taptic() {
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
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            userDefaults.set(false, forKey: "hideAlert")
            present(alert, animated: true, completion: nil)
        }
    }
}


