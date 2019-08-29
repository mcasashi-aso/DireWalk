//
//  NotificationNames.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/29.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation

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
    public static let adjustmentFavoriteDeleted = Notification.Name("adjustmentFavoriteDeleted")
}
