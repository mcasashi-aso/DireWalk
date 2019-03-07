//
//  ActivityCollectionViewCell.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

class ActivityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var aboutLable: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var unitLable: UILabel!
    
    func setData(cellData: CellData) {
        setCell()
        self.aboutLable.text = cellData.about
        self.numberLabel.text = String(cellData.number)
        self.unitLable.text = cellData.unit
    }
    
    func setCell() {
        self.aboutLable.adjustsFontSizeToFitWidth = true
        self.aboutLable.adjustsFontForContentSizeCategory = true
    }
    
}
