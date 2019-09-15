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


class ToggleTableViewCell: UITableViewCell {
    @objc let toggleSwitch = UISwitch()
    
    var didChange: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        toggleSwitch.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
        accessoryView = toggleSwitch
    }
    
    func setup(title: String, initialValue: Bool, didChange: @escaping (Bool) -> Void) {
        toggleSwitch.isOn = initialValue
        self.didChange = didChange
    }
    
    @objc func didChangeValue(_ sender: UISwitch) {
        guard let f = didChange else { return }
        f(sender.isOn)
    }
}
