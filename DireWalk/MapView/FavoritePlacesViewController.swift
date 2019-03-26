//
//  FavoritePlaces.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/20.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class FavoritePlacesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let userDefaults = UserDefaults.standard
    
    var udDatas: [Data] = []
    var places: [FavoritePlaceData] = []
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @objc func getFavorites() {
        guard let udDs = userDefaults.array(forKey: udKey.favoritePlaces.rawValue) else { return }
        let index = userDefaults.integer(forKey: udKey.editingCellIndexPath.rawValue)
        guard let place = try? JSONDecoder().decode(FavoritePlaceData.self
            , from: udDs[index] as! Data) else { return }
        udDatas.append(udDs[index] as! Data)
        places[index] = place
    }
    
    @objc func insertNewFavorite() {
        places.append(FavoritePlaceData.init(latitude: 0.0, longitude: 0.0, name: "", adress: ""))
        userDefaults.set(places.count - 1, forKey: udKey.editingCellIndexPath.rawValue)
        getFavorites()
        collectionView.insertItems(at: [IndexPath(row: places.count - 1, section: 0)])
        fitCollectionWidth()
    }
    
    @objc func deleteFavorites() {
        guard let deleted = userDefaults.array(forKey: udKey.deletedFavoritePlaces.rawValue) else { return }
        var indexPaths = [IndexPath]()
        let bigToSmallArray = (deleted as! [Int]).sorted { $1 < $0 }
        for row in bigToSmallArray {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        for index in bigToSmallArray {
            places.remove(at: index)
            udDatas.remove(at: index)
            userDefaults.set(index, forKey: udKey.adjustmentFavoriteDeleted.rawValue)
            NotificationCenter.default.post(name: .adjustmentFavoriteDeleted, object: nil)
        }
        
        collectionView.deleteItems(at: indexPaths)
        userDefaults.set(udDatas, forKey: udKey.favoritePlaces.rawValue)
        userDefaults.set([Int](), forKey: udKey.deletedFavoritePlaces.rawValue)
        
        fitCollectionWidth()
        
        if places.count == 0 {
            userDefaults.set(true, forKey: udKey.hideEditButton.rawValue)
            NotificationCenter.default.post(name: .hideEditButton, object: nil)
        }
    }
    
    @objc func hideAddFPButtonIf() {
        let latitude = userDefaults.object(forKey: udKey.annotationLatitude.rawValue) as! CLLocationDegrees
        let longitude = userDefaults.object(forKey: udKey.annotationLongitude.rawValue) as! CLLocationDegrees
        let destination = CLLocation(latitude: latitude, longitude: longitude)
        var isHidden = false
        for place in places {
            let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
            let far = destination.distance(from: placeLocation)
            if Int(far) <= 30 {
                isHidden = true
            }
        }
        userDefaults.set(isHidden, forKey: udKey.hideAddFavorite.rawValue)
        NotificationCenter.default.post(name: .hideAddFavorite, object: nil)
    }
    
    var editingCellIndexPath: Int!
    @objc func getEditingCellIndexPath() {
        editingCellIndexPath = userDefaults.integer(forKey: udKey.editingCellIndexPath.rawValue)
    }
    
    @objc func changingFavoritePlaceName() {
        var place = places[editingCellIndexPath]
        place.name = userDefaults.string(forKey: udKey.editingCellString.rawValue) ?? ""
        guard let data = try? JSONEncoder().encode(place) else { return }
        places[editingCellIndexPath] = place
        udDatas[editingCellIndexPath] = data
        userDefaults.set(udDatas, forKey: udKey.favoritePlaces.rawValue)
    }
    
    @objc func selectCell() {
        let indexPath = userDefaults.integer(forKey: udKey.selectedCellIndexPath.rawValue
        )
        let place = places[indexPath]
        userDefaults.set(place.latitude, forKey: udKey.annotationLatitude.rawValue)
        userDefaults.set(place.longitude, forKey: udKey.annotationLongitude.rawValue)
        NotificationCenter.default.post(name: .showFavoritePlace, object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row != places.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as! FavoritePlaceCell
            let place = places[indexPath.row]
            cell.myIndexPath = indexPath.row
            let deletedPlaces = userDefaults.array(forKey: udKey.deletedFavoritePlaces.rawValue) as! [Int]
            if deletedPlaces.contains(indexPath.row) {
                cell.deleted = true
            }else {
                cell.deleted = false
            }
            cell.setupCell(place: place)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonsCell", for: indexPath) as! ButtonsCell
            cell.setupCell()
            if places.count == 0 {
                userDefaults.set(true, forKey: udKey.hideEditButton.rawValue)
                cell.hideEditButton()
            }
            fitCollectionWidth()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row != places.count {
            return CGSize(width: 128, height: 160)
        }else {
            return CGSize(width: 70, height: 160)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNotificationObserver(selector: #selector(changingFavoritePlaceName),
                                notificationName: .changeFavoritePlaceName)
        addNotificationObserver(selector: #selector(getEditingCellIndexPath),
                                notificationName: .editingFavoritePlaceIndexPath)
        addNotificationObserver(selector: #selector(selectCell),
                                notificationName: .selectedFavoritePlace)
        addNotificationObserver(selector: #selector(hideAddFPButtonIf),
                                notificationName: .updateMarker)
        addNotificationObserver(selector: #selector(insertNewFavorite),
                                notificationName: .addedFavorite)
        addNotificationObserver(selector: #selector(deleteFavorites),
                                notificationName: .changeEditingMode)
        
        
        guard let udDs = userDefaults.array(forKey: udKey.favoritePlaces.rawValue) else { return }
        udDatas = udDs as! [Data]
        places = []
        for placeData in udDatas {
            guard let place = try? JSONDecoder().decode(FavoritePlaceData.self, from: placeData ) else { return }
            places.append(place)
        }
        fitCollectionWidth()
    }
    
    func addNotificationObserver(selector: Selector, notificationName: Notification.Name) {
        NotificationCenter.default.addObserver(self,
                                               selector: selector,
                                               name: notificationName,
                                               object: nil)
    }
    
    func fitCollectionWidth() {
        let screenWidth = Int(UIScreen.main.bounds.width)
        let collectionContentWidth = 24 + places.count * (128 + 16) + 70 + 24
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
