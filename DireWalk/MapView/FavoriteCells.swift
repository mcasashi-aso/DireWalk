//
//  FavoriteCells.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/20.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import UIKit


class FavoritePlaceCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var directionImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    func setupCell() {
        self.layer.cornerRadius = 16
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        self.layer.masksToBounds = false
        self.nameTextField.delegate = self
        deleteButton.layer.cornerRadius = deleteButton.bounds.height / 2
        deleteButton.layer.masksToBounds = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
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
        editButton.layer.cornerRadius = 23
        editButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 23
        addButton.layer.masksToBounds = true
    }
    
    @IBAction func toEdit() {
        editDelegate?.toEdit()
    }
    
    @IBAction func addFavorite() {
        NotificationCenter.default.post(name: .addFavorite, object: nil)
    }
    
}
