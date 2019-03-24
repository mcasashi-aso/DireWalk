//
//  Strings.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/01.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import UIKit


enum udKey: String{
    case annotationLatitude
    case annotationLongitude
    case destinationName
    case previousAnnotation
    case directoinButtonHeading
    case usingTimes
    case showFar
    case favoritePlaces
    case favoritePlaceIsEditing
    case editingCellIndexPath
    case editingCellString
    case deletedFavoritePlaces
    case selectedCellIndexPath
    case favoriteDestinationName
    case hideAddFavorite
    case hideEditButton
}

extension Notification.Name {
    public static let addFavorite = Notification.Name("addFavorite")
    public static let addedFavorite = Notification.Name("addedFavorite")
    public static let fitFavolitCollectionView = Notification.Name("fitFavolitCollectionView")
    public static let updateMarker = Notification.Name("updateMarker")
    public static let changeEditingMode = Notification.Name("changeEditingMode")
    public static let changeFavoritePlaceName = Notification.Name("changeFavoritePlaceName")
    public static let editingFavoritePlaceIndexPath = Notification.Name("editingFavoritePlaceIndexPath")
    public static let selectedFavoritePlace = Notification.Name("selectedFavoritePlace")
    public static let showFavoritePlace = Notification.Name("showFavoritePlace")
    public static let findForFavorite = Notification.Name("findForFavorite")
    public static let hideAddFavorite = Notification.Name("hideAddFavorie")
    public static let hideEditButton = Notification.Name("hideEditButton")
}

extension UIColor {
    public static let systemBlue = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    public static let myBlue = #colorLiteral(red: 0.04705882353, green: 0.3921568627, blue: 1, alpha: 1)
    public static let cover = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
    public static let superGray = #colorLiteral(red: 0.860546875, green: 0.860546875, blue: 0.860546875, alpha: 1)
}
