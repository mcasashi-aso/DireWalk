//
//  Strings.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/01.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

extension UIColor {
    public static let systemBlue = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    public static let myBlue = #colorLiteral(red: 0.04705882353, green: 0.3921568627, blue: 1, alpha: 1)
    public static let mySkyBlue = #colorLiteral(red: 0, green: 0.7490196078, blue: 1, alpha: 1)
    public static let cover = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
    public static let superGray = #colorLiteral(red: 0.860546875, green: 0.860546875, blue: 0.860546875, alpha: 1)
}

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
