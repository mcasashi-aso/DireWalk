//
//  WalkThrough.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/04/21.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

class WalkThroughViewController: UIViewController {
    
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var navigationLabel: UILabel!
    
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    
    @IBOutlet weak var swipeLabel: UILabel!
    
    @IBOutlet weak var canLabel: UILabel!
    @IBOutlet weak var directionImageView: UIImageView!
    
    @IBOutlet weak var forTextView: UITextView!
    
    @IBOutlet weak var pleaseLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutLabel.adjustsFontSizeToFitWidth = true
        selectLabel.adjustsFontSizeToFitWidth = true
        swipeLabel.adjustsFontSizeToFitWidth = true
        canLabel.adjustsFontSizeToFitWidth = true
        pleaseLabel.adjustsFontSizeToFitWidth = true
        
        aboutLabel.text = NSLocalizedString("aboutThisApp", comment: "")
        navigationLabel.text = NSLocalizedString("navigation", comment: "")
        selectLabel.text = NSLocalizedString("select", comment: "")
        swipeLabel.text = NSLocalizedString("swipeFromLeftEdge", comment: "")
        canLabel.text = NSLocalizedString("always", comment: "")
        forTextView.text = NSLocalizedString("thisIsFor", comment: "")
        pleaseLabel.text = NSLocalizedString("pleaseAllowLocation", comment: "")
        
        mapImageView.image = UIImage(named: "Map")?.withRenderingMode(.alwaysTemplate)
        mapImageView.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        directionImageView.image = UIImage(named: "Direction")?.withRenderingMode(.alwaysTemplate)
        directionImageView.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        directionImageView.transform = CGAffineTransform(rotationAngle: (45 * CGFloat.pi / 180))
        
        iconImageView.layer.cornerRadius = iconImageView.bounds.height / 5
    }
    
}
