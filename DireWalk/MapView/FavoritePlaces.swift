//
//  FavoritePlaces.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/20.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import UIKit

protocol FavoritePlacesViewControllerDelegate {
    func showPlace()
}

class FavoritePlacesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ButtonsCellEditDelegate {
    
    var delegate: FavoritePlacesViewControllerDelegate?
    
    let userDefaults = UserDefaults.standard
    
    var datas: [FavoritePlaceData] = []
    
    var editingCells = false
    func toEdit() {
        if editingCells {
            editingCells = false
        }else {
            editingCells = true
        }
        reloadCollectionView()
    }
    @objc func notShowingFavoritePlace() {
        editingCells = false
        reloadCollectionView()
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @objc func reloadCollectionView() {
        print("reload")
        if let data = userDefaults.object(forKey: ud.key.favoritePlaces.rawValue) as? Data {
            datas = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [FavoritePlaceData]
        }
        collectionView.reloadData()
        fitCollectionWidth()
        print(datas)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row != datas.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as! FavoritePlaceCell
            cell.nameTextField.text = datas[indexPath.row].name
            cell.adressLabel.text = datas[indexPath.row].adress
            cell.setupCell()
            if !editingCells {
                cell.deleteButton.isHidden = true
                cell.nameTextField.isEnabled = false
            }else {
                cell.deleteButton.isHidden = false
                cell.nameTextField.isEnabled = true
            }
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonsCell", for: indexPath) as! ButtonsCell
            cell.setupButtons()
            cell.editDelegate = self
            if datas.count != 0 {
                cell.editButton.isHidden = false
            }else {
                cell.editButton.isHidden = true
            }
            if !editingCells {
                cell.addButton.isEnabled = true
                cell.addButton.backgroundColor = UIColor.myBlue
                cell.editButton.backgroundColor = UIColor.myBlue
                cell.editButton.setImage(UIImage(named: "Edit"), for: .normal)
            }else {
                cell.addButton.isEnabled = false
                cell.addButton.backgroundColor = UIColor.gray
                cell.editButton.backgroundColor = UIColor.white
                cell.editButton.setImage(UIImage(named: "Editing"), for: .normal)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row != datas.count {
            return CGSize(width: 128, height: 160)
        }else {
            return CGSize(width: 70, height: 160)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadCollectionView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadCollectionView),
                                               name: .reloadFavorite,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notShowingFavoritePlace),
                                               name: .endEditing,
                                               object: nil)
    }
    
    func fitCollectionWidth() {
        let screenWidth = Int(UIScreen.main.bounds.width)
        let collectionContentWidth = 24 + datas.count * (128 + 16) + 70 + 24
        let width: Int!
        if collectionContentWidth > screenWidth {
            width = screenWidth
        }else {
            width = collectionContentWidth
        }
        userDefaults.set(Float(screenWidth - width), forKey: "scrollViewLeadingConstraint")
        NotificationCenter.default.post(name: .fitFavolitCollectionView, object: nil)
    }
    
}
