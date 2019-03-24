//
//  TableViewCells.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/11.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ChangeShowFarCell: UITableViewCell {
    @objc let changeSwitch = UISwitch()
    let userDefaults = UserDefaults.standard
    override func awakeFromNib() {
        super.awakeFromNib()
        changeSwitch.addTarget(self, action: #selector(changeShowFar), for: UIControl.Event.valueChanged)
        if userDefaults.bool(forKey: udKey.showFar.rawValue) {
            changeSwitch.isOn = true
        }else {
            changeSwitch.isOn = false
        }
        accessoryView = changeSwitch
    }
    @objc func changeShowFar() {
        if changeSwitch.isOn {
            userDefaults.set(true, forKey: udKey.showFar.rawValue)
        }else {
            userDefaults.set(false, forKey: udKey.showFar.rawValue)
        }
    }
}
