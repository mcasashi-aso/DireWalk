//
//  UISearchBar.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/12/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

extension UISearchBar {
    var cancelButton: UIButton? {
        value(forKey: "cancelButton") as? UIButton
    }
}
