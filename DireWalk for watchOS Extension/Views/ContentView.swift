//
//  ContentView.swift
//  SwiftUI_watch_TEST WatchKit Extension
//
//  Created by Masashi Aso on 2019/12/11.
//  Copyright © 2019 Masashi Aso. All rights reserved.
//

import Combine
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            if model.place == nil {
                Image(systemName: "location.north.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .padding(45)
                    .frame(minWidth: .zero, maxWidth: .infinity,
                           minHeight: .zero, maxHeight: .infinity)
                    .rotationEffect(.degrees(model.heading ?? 45))
                    .contextMenu {
                        
                        NavigationLink(
                            destination: SearchView()
                        ) {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .imageScale(.large)
                                Text("Search")
                            }
                        }
                        
                        NavigationLink(
                            destination: FavoriteList()
                        ) {
                            VStack {
                                Image(systemName: "list.bullet")
                                    .imageScale(.large)
                                Text("Favorites")
                            }
                        }
                }
            } else {
                VStack {
                    Text("Welcome DireWalk!")
                    
                    NavigationLink(
                        destination: FavoriteList()
                    ) {
                        Text("Favorites")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Model())
    }
}
