//
//  FavoriteCells.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/20.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class FavoritePlaceCell: UICollectionViewCell {
    
    var myIndexPath: Int!
    var placeData: FavoritePlaceData!
    var deleted = false
    
    var locationManager = CLLocationManager() {
        didSet{
            locationManager.delegate = self
            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var directionImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var underlineForNameTextField: UIView!
    @IBOutlet weak var toSelectButton: UIButton!
    
    @IBOutlet weak var underLineWidth: NSLayoutConstraint!
    
    let userDefaults = UserDefaults.standard
    
    let coverView = UIView()
    let restoreButton = UIButton()
    
    var destinationHeadingRadian = CGFloat()
    
    func setupCell(place: FavoritePlaceData) {
        self.placeData = place
        self.nameTextField.text = placeData.name
        self.adressLabel.text = placeData.adress
        
        self.layer.cornerRadius = 16
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        nameTextField.delegate = self
        nameTextField.adjustsFontSizeToFitWidth = true
        distanceLabel.adjustsFontSizeToFitWidth = true
        deleteButton.layer.cornerRadius = deleteButton.bounds.height / 2
        deleteButton.layer.masksToBounds = true
        
        
        coverView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        coverView.backgroundColor = UIColor.cover
        coverView.layer.cornerRadius = 16
        coverView.layer.masksToBounds = true
        coverView.isUserInteractionEnabled = false
        coverView.alpha = 0.0
        self.addSubview(coverView)
        restoreButton.addTarget(self, action: #selector(tapRestore), for: .touchUpInside)
        restoreButton.setTitle(NSLocalizedString("restore", comment: ""), for: .normal)
        restoreButton.frame = CGRect(x: 14, y: 58, width: 100, height: 44)
        restoreButton.backgroundColor = UIColor.systemBlue
        restoreButton.layer.cornerRadius = 7
        restoreButton.layer.masksToBounds = true
        self.addSubview(restoreButton)
        restoreButton.alpha = 0.0
        restoreButton.isUserInteractionEnabled = false
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeEdit), name: .changeEditingMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(judgeSelected), name: .updateMarker, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustIndexPath), name: .adjustmentFavoriteDeleted, object: nil)
        
        changeEdit()
        
        if userDefaults.bool(forKey: udKey.favoritePlaceIsEditing.rawValue) {
            if deleted {
                tapDelete()
            }else {
                tapRestore()
            }
        }
    }
    
    @objc func adjustIndexPath () {
        let deletedIndex = userDefaults.integer(forKey: udKey.adjustmentFavoriteDeleted.rawValue)
        if myIndexPath > deletedIndex {
            myIndexPath -= 1
        }
    }
    
    @objc func changeEdit() {
        if userDefaults.bool(forKey: udKey.favoritePlaceIsEditing.rawValue) {
            nameTextField.isUserInteractionEnabled = true
            toSelectButton.isEnabled = false
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction, .curveEaseInOut], animations: {
                self.deleteButton.alpha = 1.0
                let view = self.underlineForNameTextField
                view!.frame = CGRect(x: (view?.frame.minX)!, y: (view?.frame.minY)!, width: 108, height: 1)
            }, completion: { finished in
                self.underLineWidth.constant = 108
                self.deleteButton.isUserInteractionEnabled = true
            })
        }else {
            nameTextField.isUserInteractionEnabled = false
            deleteButton.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction, .curveEaseInOut], animations: {
                self.deleteButton.alpha = 0.0
                let view = self.underlineForNameTextField
                view!.frame = CGRect(x: (view?.frame.minX)!, y: (view?.frame.minY)!, width: 0, height: 1)
            }, completion: { finished in
                self.underLineWidth.constant = 0
                self.toSelectButton.isEnabled = true
            })
        }
    }
    
    @IBAction func tapDelete() {
        deleteButton.alpha = 0.0
        deleteButton.isUserInteractionEnabled = false
        coverView.alpha = 1.0
        restoreButton.alpha = 1.0
        restoreButton.isUserInteractionEnabled = true
        
        guard var deletedArray = userDefaults.array(forKey: udKey.deletedFavoritePlaces.rawValue) else { return }
        deletedArray.append(myIndexPath)
        let setArray = NSOrderedSet(array: deletedArray)
        deletedArray = setArray.array as! [Int]
        userDefaults.set(deletedArray, forKey: udKey.deletedFavoritePlaces.rawValue)
    }
    
    @objc func tapRestore() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction, .curveEaseInOut], animations: {
            self.deleteButton.alpha = 1.0
            self.coverView.alpha = 0.0
            self.restoreButton.alpha = 0.0
        }) { finished in
            self.deleteButton.isUserInteractionEnabled = true
            self.restoreButton.isUserInteractionEnabled = false
        }
        
        guard var deletedArray: [Int] = userDefaults.array(forKey: udKey.deletedFavoritePlaces.rawValue) as? [Int] else { return }
        let setArray = NSOrderedSet(array: deletedArray)
        deletedArray = setArray.array as! [Int]
        guard let index = deletedArray.firstIndex(of: myIndexPath) else  { return }
        deletedArray.remove(at: index)
        userDefaults.set(deletedArray, forKey: udKey.deletedFavoritePlaces.rawValue)
    }
    
    @IBAction func selectCell() {
        self.backgroundColor = UIColor.superGray
        userDefaults.set(myIndexPath, forKey: udKey.selectedCellIndexPath.rawValue)
        NotificationCenter.default.post(name: .selectedFavoritePlace, object: nil)
    }
    
}

extension FavoritePlaceCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        if newString?.count != 0 {
            placeData.name = newString!
            userDefaults.set(newString, forKey: udKey.editingCellString.rawValue)
            NotificationCenter.default.post(name: .changeFavoritePlaceName, object: nil)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        userDefaults.set(myIndexPath, forKey: udKey.editingCellIndexPath.rawValue)
        NotificationCenter.default.post(name: .editingFavoritePlaceIndexPath, object: nil)
        return true
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

extension FavoritePlaceCell: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        showDistance()
        judgeSelected()
    }
    
    func showDistance() {
        let location = CLLocation(latitude: placeData.latitude, longitude: placeData.longitude)
        let far = location.distance(from: locationManager.location!)
        var distance: String = ""
        var unit: String = ""
        
        if 50 > Int(far) {
            distance = "\(Int(far))"
            unit = "m"
        }else if 500 > Int(far){
            distance = "\((Int(far) / 10 + 1) * 10)"
            unit = "m"
        }else {
            let doubleNum = Double(Int(far) / 100 + 1) / 10
            if doubleNum.truncatingRemainder(dividingBy: 1.0) == 0.0 {
                distance = "\(Int(doubleNum))"
                unit = "km"
            }else {
                distance = "\(doubleNum)"
                unit = "km"
            }
        }
        
        let distanceAttributed: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 25),
            .foregroundColor : UIColor.black
        ]
        let unitAttributed: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 15),
            .foregroundColor : UIColor.black
        ]
        let attributedDistance = NSAttributedString(string: distance, attributes: distanceAttributed)
        let attributedUnit = NSAttributedString(string: unit, attributes: unitAttributed)
        let labelText = NSMutableAttributedString()
        labelText.append(attributedDistance)
        labelText.append(attributedUnit)
        distanceLabel.attributedText = labelText
    }
    
    @objc func judgeSelected() {
        let destinationlatitude = userDefaults.object(forKey: udKey.annotationLatitude.rawValue) as! CLLocationDegrees
        let destinationLongitude = userDefaults.object(forKey: udKey.annotationLongitude.rawValue) as! CLLocationDegrees
        if destinationlatitude == placeData.latitude &&
            destinationLongitude == placeData.longitude {
            self.backgroundColor = UIColor.lightGray
            userDefaults.set(placeData.name, forKey: udKey.destinationName.rawValue)
            NotificationCenter.default.post(name: .findForFavorite, object: nil)
        }else {
            self.backgroundColor = UIColor.white
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        destinationHeading()
        directionImageView.transform = CGAffineTransform(rotationAngle: (destinationHeadingRadian - CGFloat(newHeading.magneticHeading) - 45) * CGFloat.pi / 180)
    }
    
    func destinationHeading() {
        let destinationLatitude = toRadian(placeData.latitude)
        let destinationLongitude = toRadian(placeData.longitude)
        let userLatitude = toRadian((locationManager.location?.coordinate.latitude)!)
        let userLongitude = toRadian((locationManager.location?.coordinate.longitude)!)
        
        let difLongitude = destinationLongitude - userLongitude
        let y = sin(difLongitude)
        let x = cos(userLatitude) * tan(destinationLatitude) - sin(userLatitude) * cos(difLongitude)
        let p = atan2(y, x) * 180 / CGFloat.pi
        if p < 0 {
            destinationHeadingRadian = 360 + p
        }
        destinationHeadingRadian = p
    }
    func toRadian(_ angle: CLLocationDegrees) -> CGFloat{
        let floatAngle = CGFloat(angle)
        return floatAngle * CGFloat.pi / 180
    }
}



class ButtonsCell: UICollectionViewCell {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var editButtonHidden = false
    
    func setupButton(button: UIButton) {
        button.layer.cornerRadius = 25
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func setupCell(){
        setupButton(button: editButton)
        setupButton(button: addButton)
        isNotEnabledAddFavoriteButton()
        hideEditButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeEdit), name: .changeEditingMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isNotEnabledAddFavoriteButton), name: .hideAddFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideEditButton), name: .hideEditButton, object: nil)
    }
    
    @IBAction func toEdit() {
        if !UserDefaults.standard.bool(forKey: udKey.favoritePlaceIsEditing.rawValue){
            UserDefaults.standard.set(true, forKey: udKey.favoritePlaceIsEditing.rawValue)
            NotificationCenter.default.post(name: .changeEditingMode, object: nil)
        }else {
            UserDefaults.standard.set(false, forKey: udKey.favoritePlaceIsEditing.rawValue)
            NotificationCenter.default.post(name: .changeEditingMode, object: nil)
        }
        
    }
    
    @objc func changeEdit() {
        if UserDefaults.standard.bool(forKey: udKey.favoritePlaceIsEditing.rawValue) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowUserInteraction, .curveEaseInOut, .allowAnimatedContent], animations: {
                self.editButton.backgroundColor = UIColor.white
                self.editButton.transform = CGAffineTransform(rotationAngle: (45 * CGFloat.pi / 180))
                self.editButton.setImage(UIImage(named: "Editing"), for: .normal)
                self.addButton.backgroundColor = UIColor.gray
            }, completion: nil)
            self.addButton.isUserInteractionEnabled = false
        }else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowUserInteraction, .curveEaseInOut, .allowAnimatedContent], animations: {
                self.editButton.backgroundColor = UIColor.myBlue
                self.editButton.transform = CGAffineTransform(rotationAngle: 0)
                self.editButton.setImage(UIImage(named: "Edit"), for: .normal)
                self.addButton.backgroundColor = UIColor.myBlue
            }, completion: { finished in
                self.addButton.isUserInteractionEnabled = true
            })
        }
        UserDefaults.standard.set([Int](), forKey: udKey.deletedFavoritePlaces.rawValue)
    }
    
    @objc func isNotEnabledAddFavoriteButton() {
        if UserDefaults.standard.bool(forKey: udKey.hideAddFavorite.rawValue) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowUserInteraction, .curveEaseInOut, .allowAnimatedContent], animations: {
                self.addButton.backgroundColor = UIColor.gray
            }, completion: { finished in
                self.addButton.backgroundColor = UIColor.gray
            })
            self.addButton.isUserInteractionEnabled = false
        }else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowUserInteraction, .curveEaseInOut, .allowAnimatedContent], animations: {
                self.addButton.backgroundColor = UIColor.myBlue
            }, completion: { finished in
                self.addButton.backgroundColor = UIColor.myBlue
                self.addButton.isUserInteractionEnabled = true
            })
        }
    }
    
    @objc func hideEditButton() {
        if UserDefaults.standard.bool(forKey: udKey.hideEditButton.rawValue) {
            self.editButton.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction, .curveEaseInOut], animations: {
                self.editButton.alpha = 0.0
            }) { finished in
                self.editButton.alpha = 0.0
            }
        }else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction, .curveEaseInOut], animations: {
                self.editButton.alpha = 1.0
            }) { finished in
                self.editButton.alpha = 1.0
                self.editButton.isUserInteractionEnabled = true
            }
        }
        
    }
    
    @IBAction func addFavorite() {
        NotificationCenter.default.post(name: .addFavorite, object: nil)
        UserDefaults.standard.set(true, forKey: udKey.hideAddFavorite.rawValue)
        isNotEnabledAddFavoriteButton()
        UserDefaults.standard.set(false, forKey: udKey.hideEditButton.rawValue)
        hideEditButton()
    }
    
}
