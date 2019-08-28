//
//  SelectColorViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import UIKit

class SelectColorViewController: UIViewController {
    
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var slider: MySlider!
    @IBOutlet weak var whiteAboutTextView: UITextView!
    @IBOutlet weak var blackAboutTextView: UITextView!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var colorAboutHeight: NSLayoutConstraint!
    @IBOutlet weak var arrowImageWidth: NSLayoutConstraint!
    
    var arrowColorWhite: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrowColorWhite = CGFloat(UserDefaults.standard.float(forKey: udKey.arrowColorWhite.rawValue))
        
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = Float(arrowColorWhite)
        slider.minimumTrackTintColor = UIColor.black
        slider.maximumTrackTintColor = UIColor.white
        
        self.navigationItem.title = NSLocalizedString("arrowColor", comment: "")
        arrowImageView.image = UIImage(named: "Direction")?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = UIColor(white: arrowColorWhite, alpha: 1)
        arrowImageView.transform = CGAffineTransform(rotationAngle: (45 * CGFloat.pi / 180))
        whiteAboutTextView.text = NSLocalizedString("whiteColorAbout", comment: "")
        blackAboutTextView.text = NSLocalizedString("blackColorAbout", comment: "")
        if UIScreen.main.bounds.width < 375 {
            whiteAboutTextView.font = UIFont.preferredFont(forTextStyle: .title2)
            blackAboutTextView.font = UIFont.preferredFont(forTextStyle: .title2)
            colorAboutHeight.constant = 145
        }
        previewLabel.text = NSLocalizedString("preview", comment: "")
    }
    
    @IBAction func changeValue(_ sender: UISlider) {
        arrowColorWhite = CGFloat(sender.value)
        arrowImageView.tintColor = UIColor(white: arrowColorWhite, alpha: 1)
        
        UserDefaults.standard.set(Float(arrowColorWhite), forKey: udKey.arrowColorWhite.rawValue)
    }
    
}
