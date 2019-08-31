//
//  TableViewSection.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/31.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

class TableViewSection {
    var cells: [SettingsTableViewCellType]
    var header: String?
    var footer: String?
    
    init(cells: [SettingsTableViewCellType],
         header: String? = nil, footer: String? = nil) {
        self.cells = cells
        self.header = header
        self.footer = footer
    }
}
