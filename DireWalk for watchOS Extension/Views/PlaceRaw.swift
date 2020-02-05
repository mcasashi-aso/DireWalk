//
//  PlaceRaw.swift
//  SwiftUI_watch_TEST WatchKit Extension
//
//  Created by Masashi Aso on 2019/12/13.
//  Copyright © 2019 Masashi Aso. All rights reserved.
//

import SwiftUI

struct PlaceRaw: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.place?.title ?? "Place")
                    .font(.body)
                Text(model.distance.flatMap(distanceWithUnit(_:)) ?? "error")
                    .font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "location.north")
                .imageScale(.large)
                .rotationEffect(.degrees(model.heading ?? 45))
        }.padding()
    }
    
    func distanceWithUnit(_ distance: Double) -> String {
        switch distance {
        case ..<100:  return "\(Int(distance))m"
        case ..<1000: return "\((Int(distance)/10+1) * 10)m"
        default:
            let double = Double(Int(distance)/100+1) / 10
            if double.truncatingRemainder(dividingBy: 1.0) == 0 {
                return ("\(Int(double))km")
            } else {
                return "\(double)km"
            }
        }
    }
}

struct PlaceRaw_Previews: PreviewProvider {
    static var previews: some View {
        PlaceRaw(model: Model(place: Place(latitude: 1, longitude: 1, title: "Home", address: "address")))
            .previewLayout(.fixed(width: 200, height: 50))
    }
}
