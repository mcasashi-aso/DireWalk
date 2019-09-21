//
//  DirectionViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation

final class DirectionViewController: UIViewController {
    
    static func create() -> DirectionViewController {
        let sb = UIStoryboard(name: "Direction", bundle: nil)
        return sb.instantiateInitialViewController() as! DirectionViewController
    }
    
    // MARK: - Models
    private let userDefaults = UserDefaults.standard
    private let viewModel = ViewModel.shared
    private let settings = Settings.shared
    
    private var isHidable = true {
        didSet {
            guard !isHidable else { return }
            // 1秒経ったら変更可能にする
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isHidable = true
            }
        }
    }
    
    // MARK: - Views
    @IBOutlet weak var headingImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func updateFarLabel() {
        distanceLabel.attributedText = viewModel.farLabelText
    }
    
    func updateHeadingImage() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            let affineTransform = CGAffineTransform(rotationAngle: self.viewModel.headingImageAngle)
            self.headingImageView.transform = affineTransform
        }, completion: nil)
    }
    
    func applyToSettings() {
        headingImageView.image = settings.arrowImage.image.withRenderingMode(.alwaysTemplate)
        headingImageView.tintColor = UIColor(white: settings.arrowColor, alpha: 1)
        updateFarLabel()
    }

    // MARK: - View's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        applyToSettings()
        updateFarLabel()
        updateHeadingImage()
    }
    
    // MARK: - Gestures
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let percent = touch.force / touch.maximumPossibleForce
        if percent == 1.0 {
            changeHiddenState()
        }
    }
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer! {
        didSet {
            longPressGestureRecognizer.minimumPressDuration = 0.5
        }
    }
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIPanGestureRecognizer.State.began {
            changeHiddenState()
        }
    }
    func changeHiddenState() {
        guard isHidable else { return }
        isHidable = false
        guard viewModel.canHidden else { return }
        let isHiding = viewModel.state == .hideControllers
        viewModel.state = isHiding ? .direction : .hideControllers
    }
}
