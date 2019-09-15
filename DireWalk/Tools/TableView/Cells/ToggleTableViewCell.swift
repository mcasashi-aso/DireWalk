//
//  ToggleTableViewCell.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/15.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class ToggleTableViewCell: UITableViewCell, Nibable {
    @objc let toggleSwitch = UISwitch()
    
    var didChange: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        toggleSwitch.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
        accessoryView = toggleSwitch
    }
    
    func setup(title: String, initialValue: Bool, didChange: @escaping (Bool) -> Void) {
        textLabel?.text = title
        toggleSwitch.isOn = initialValue
        self.didChange = didChange
    }
    
    @objc func didChangeValue(_ sender: UISwitch) {
        guard let f = didChange else { return }
        f(sender.isOn)
    }
}

