//
//  ActivityCollectionViewCell.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ActivityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var aboutLable: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var unitLable: UILabel!
    
    @IBOutlet weak var aboutLabelTopInset: NSLayoutConstraint!
    @IBOutlet weak var aboutLabelLeftInset: NSLayoutConstraint!
    @IBOutlet weak var unitLabelBottomInset: NSLayoutConstraint!
    @IBOutlet weak var unitLabelRightInset: NSLayoutConstraint!
    
    func setData(cellData: CellData) {
        setCell()
        self.aboutLable.text = cellData.about
        self.numberLabel.text = String(cellData.number)
        self.unitLable.text = cellData.unit
    }
    
    func setCell() {
        aboutLable.adjustsFontSizeToFitWidth = true
        aboutLable.adjustsFontForContentSizeCategory = true
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.adjustsFontForContentSizeCategory = true
        unitLable.adjustsFontSizeToFitWidth = true
        unitLable.adjustsFontForContentSizeCategory = true
    }
    
    func setInset(constant: CGFloat) {
        aboutLabelTopInset.constant = constant - 2
        aboutLabelLeftInset.constant = constant
        unitLabelBottomInset.constant = constant - 2
        unitLabelRightInset.constant = constant
    }
    
}


class AdCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var adView: GADBannerView! {
        didSet{
            adView.adSize = kGADAdSizeLargeBanner
        }
    }
    
    
}
