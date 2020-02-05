//
//  HostingController.swift
//  SwiftUI_watch_TEST WatchKit Extension
//
//  Created by Masashi Aso on 2019/12/11.
//  Copyright © 2019 Masashi Aso. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

struct _ContentView: View {
    var body: some View {
        ContentView().environmentObject(Model())
            .onAppear {  }
    }
}

class HostingController: WKHostingController<_ContentView> {
    override var body: _ContentView {
        return _ContentView()
    }
}
