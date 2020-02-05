//
//  NSAttributedString++.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/12/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

extension NSAttributedString {
    enum MyAttributes {
        case white40, white80
        
        func value() -> [NSAttributedString.Key : Any] {
            switch self {
            case .white80: return [.font: UIFont.systemFont(ofSize: 80),
                                   .foregroundColor: UIColor.white]
            case .white40: return [.font : UIFont.systemFont(ofSize: 40),
                                   .foregroundColor : UIColor.white]
            }
        }
    }
    
    static func get(_ string: String, attributes: MyAttributes) -> NSAttributedString {
        NSAttributedString(string: string, attributes: attributes.value())
    }
}
