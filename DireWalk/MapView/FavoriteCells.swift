//
//  FavoriteCells.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/20.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import UIKit


class FavoritePlaceCell: UICollectionViewCell {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var directionImageView: UIImageView!
    
    func setupCell() {
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
    }
    
}



protocol ButtonsCellEditDelegate {
    func toEdit()
}

class ButtonsCell: UICollectionViewCell {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var editDelegate: ButtonsCellEditDelegate?
    
    func setupButtons() {
        editButton.layer.cornerRadius = editButton.bounds.height / 2
        editButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = addButton.bounds.height / 2
        addButton.layer.masksToBounds = true
    }
    
    func hideEditButton() {
        editButton.isHidden = true
    }
    
    @IBAction func toEdit() {
        editDelegate?.toEdit()
    }
    
    @IBAction func addFavorite() {
        NotificationCenter.default.post(name: .addFavorite, object: nil)
    }
    
}
