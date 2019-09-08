//
//  Strings.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/01.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import MapKit

func wait(_ waitContinuation: @escaping (() -> Bool), compleation: @escaping (() -> Void)) {
    var wait = waitContinuation()
    // 0.01秒周期で待機条件をクリアするまで待ちます。
    let semaphore = DispatchSemaphore(value: 0)
    DispatchQueue.global().async {
        while wait {
            DispatchQueue.main.async {
                wait = waitContinuation()
                semaphore.signal()
            }
            semaphore.wait()
            Thread.sleep(forTimeInterval: 0.01)
        }
        // 待機条件をクリアしたので通過後の処理を行います。
        DispatchQueue.main.async {
            compleation()
        }
    }
}


extension CLPlacemark {
    var address: String {
        let components = [self.administrativeArea, self.locality, self.thoroughfare, self.subThoroughfare]
        return components.compactMap { $0 }.joined(separator: "")
    }
}


extension String {
    var localized: String {
        NSLocalizedString(self, comment: "localized string with \(self)")
    }
    
    var localizedYet: String {
        "Please Localize \"\(self)\""
    }
}


extension Date {
    func isSameDay(to date: Date) -> Bool {
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self) == dateFormatter.string(from: date)
    }
}

let dateFormatter = DateFormatter()

extension Array {
    public subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
