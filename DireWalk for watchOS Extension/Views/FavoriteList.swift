//
//  FavoriteList.swift
//  SwiftUI_watch_TEST WatchKit Extension
//
//  Created by Masashi Aso on 2019/12/12.
//  Copyright © 2019 Masashi Aso. All rights reserved.
//

import Combine
import SwiftUI

struct FavoriteList: View {
    
    @ObservedObject var controller = FavoritesController()
    
    var body: some View {
        VStack {
            if controller.favorites.isEmpty {
                VStack(alignment: .leading) {
                    Text("No Favorites").font(.title)
                    Text("Please add your favorite places on iPhone")
                }
            } else {
                List {
                    ForEach(controller.sortedModels) { model in
                        NavigationLink(destination: Text(model.place?.title ?? "place")) {
                            PlaceRaw(model: model)
                        }
                    }
                    .onDelete { $0.forEach {self.controller.sortedModels.remove(at: $0) } }
                }
            }
        }
    }
}

struct FavoriteList_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteList()
    }
}
