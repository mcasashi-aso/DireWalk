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
    
    func toEdit() {
        
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
        fitCollectionWidth()
        collectionView.reloadData()
        print(datas)
        for value in datas {
            print(value.name)
            print(value.adress)
            print(value.latitude)
        }
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
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonsCell", for: indexPath) as! ButtonsCell
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
    }
    
    @IBOutlet weak var collectionViewLeading: NSLayoutConstraint!
    func fitCollectionWidth() {
        print("fit")
        let screenWidth = Int(UIScreen.main.bounds.width)
        let collectionContentWidth = 24 + datas.count * (128 + 16) + 70 + 24
        let width: Int!
        if collectionContentWidth > screenWidth {
            width = screenWidth
        }else {
            width = collectionContentWidth
        }
        collectionViewLeading.constant = CGFloat(screenWidth - width)
    }
    
}
