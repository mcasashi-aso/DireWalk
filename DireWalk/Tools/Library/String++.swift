//
//  String++.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/12/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        #if DEBUG
        if self == NSLocalizedString(self, comment: "") {
            print("Please Localize \"\(self)\"")
        }
        #endif
        return NSLocalizedString(self, comment: self)
    }
}
