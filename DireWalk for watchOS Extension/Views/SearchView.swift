//
//  DestinationView.swift
//  SwiftUI_watch_TEST WatchKit Extension
//
//  Created by Masashi Aso on 2019/12/12.
//  Copyright © 2019 Masashi Aso. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var model: Model
    
    @State var text = ""
    
    var body: some View {
        List {
            TextField("Search", text: $text)
                .textContentType(.addressCity)
            
            Section(header: Text("HISTORY")) {
                ForEach(["History", "of", "Search"], id: \.self) { h in
                    Text(h)
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(Model())
    }
}
