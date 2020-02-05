//
//  MapView.swift
//  SwiftUI_watch_TEST WatchKit Extension
//
//  Created by Masashi Aso on 2019/12/13.
//  Copyright © 2019 Masashi Aso. All rights reserved.
//

import SwiftUI

struct MapView: WKInterfaceObjectRepresentable {
    
    func makeWKInterfaceObject(context: Context) -> WKInterfaceMap {
        return WKInterfaceMap()
    }
    
    func updateWKInterfaceObject(_ mapObject: WKInterfaceMap, context: Context) {
        
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
