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
    private let model = Model.shared
    
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
        let affineTransform = CGAffineTransform(rotationAngle: viewModel.headingImageAngle)
        headingImageView.transform = affineTransform
    }

    // MARK: - View's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "Direction")!.withRenderingMode(.alwaysTemplate)
        headingImageView.image = image
        distanceLabel.adjustsFontSizeToFitWidth = true
        
        updateFarLabel()
        updateHeadingImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let whiteValue = viewModel.settings.arrowColor
        if #available(iOS 13, *) {
            headingImageView.image?.withTintColor(UIColor(white: whiteValue, alpha: 1),
                                                  renderingMode: .alwaysTemplate)
        }
        headingImageView.tintColor = UIColor(white: whiteValue, alpha: 1)
        updateFarLabel()
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
        let isHiding = viewModel.state == .hideControllers
        viewModel.state = isHiding ? .direction : .hideControllers
    }
}
