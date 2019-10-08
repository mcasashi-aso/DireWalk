//
//  ContentView.swift
//  DireWalk for watchOS Extension
//
//  Created by Masashi Aso on 2019/10/08.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Form {
            List(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
                Text("Hello, World!")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
