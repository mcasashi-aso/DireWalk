//
//  TableViewCells.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/11.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

protocol NibReusable {
    static var identifier: String { get }
    static var nib: UINib { get }
}
extension NibReusable {
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: identifier, bundle: Bundle(for: self as! AnyClass)) }
}

extension UITableView {
    func getCell<Cell: NibReusable & UITableViewCell>(_ type: Cell.Type = Cell.self, indexPath: IndexPath) -> Cell {
        if let reuseCell = dequeueReusableCell(withIdentifier: type.identifier) as? Cell {
            return reuseCell
        }else {
            register(type)
            return dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as! Cell
        }
    }
    
    func register<Cell: NibReusable & UITableViewCell>(_ type: Cell.Type) {
        register(Cell.nib, forCellReuseIdentifier: type.identifier)
    }
}
