//
//  Date++.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/12/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import Foundation

extension Date {
    func isSameDay(to date: Date) -> Bool {
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self) == dateFormatter.string(from: date)
    }
}
let dateFormatter = DateFormatter()
