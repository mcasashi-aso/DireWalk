//
//  DirectionViewModel.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/24.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation
import MapKit

/*
 まだ使っていない。
 ViewModelを各Viewごとに切り出したい。
 Model -> ViewModelの伝搬法が現状Notificationしかないため迷走中
 Rxなどは一対多行けるのかな？
 */

final class DirectionViewModel {
    
    // MARK: - Singleton
    static let shared = DirectionViewModel()
    private init() {
        
    }
    
    private let model = Model.shared
    
    // MARK: - State
    enum Status { case map, search, favorite }
    var state: Status = .map
    
    // MARK: - Map
    var annotation: Annotation? {
        guard let place = model.place else { return nil }
        return Annotation(place: place)
    }
    
    // MARK: - Search
    @UserDefault(.favoritePlaces, defaultValue: Set<Place>())
    private var favoritePlaces: Set<Place>
    var searchText = ""
    private var searchResult = [Place]()
    var searchTableViewElements = [Place]()
    
    func updateTableView() {
        let array = searchText.isEmpty ? Array(favoritePlaces) : searchResult
        searchTableViewElements = array
    }
    
    func search() {
        if searchText.isEmpty {
            searchResult = []
        }
        
        let matchedTitleFavorites = Array(favoritePlaces.filter { place in
            place.title?.contains(searchText) ?? false })
        let matchedAddressFavorites = Array(favoritePlaces.filter { place in
            place.address?.contains(searchText) ?? false })
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: model.currentLocation.coordinate,
                                            latitudinalMeters: 50_000, longitudinalMeters: 50_000)
        MKLocalSearch(request: request).start { result, error in
            guard let mapItems = result?.mapItems, error == nil else { return }
            let results = mapItems.map { item in
                Place(coordinate: item.placemark.coordinate,
                      title: item.name ?? item.placemark.title ?? item.placemark.address,
                      address: item.placemark.address)
            }
            self.searchResult = matchedTitleFavorites + matchedAddressFavorites + results
        }
    }
}
