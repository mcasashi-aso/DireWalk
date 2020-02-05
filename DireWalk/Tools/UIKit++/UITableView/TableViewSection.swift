//
//  TableViewSection.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/31.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

protocol TableViewCellType {}

struct TableViewSection<CellType: TableViewCellType> {
    var cells: [CellType]
    var header: String?
    var footer: String?
    
    init(cells: [CellType], header: String? = nil, footer: String? = nil) {
        self.cells = cells
        self.header = header
        self.footer = footer
    }
}

// うーん上手くいかん
protocol TableViewSectionDataSource: UITableViewDataSource {
    associatedtype CellType: TableViewCellType
    var sections: [TableViewSection<CellType>] { get set }
}

extension TableViewSectionDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cells.count
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }
}
