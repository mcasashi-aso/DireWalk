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

// TODO: ToggleCellでまとめたい…

class ChangeShowFarCell: UITableViewCell {
    @objc let changeSwitch = UISwitch()
    private let viewModel = ViewModel.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeSwitch.addTarget(self, action: #selector(changeShowFar), for: UIControl.Event.valueChanged)
        changeSwitch.isOn = !viewModel.showFar
        accessoryView = changeSwitch
    }
    
    @objc func changeShowFar() {
        viewModel.showFar = !changeSwitch.isOn
    }
}

class ChangeAlwaysDarkModeCell: UITableViewCell {
    @objc let changeSwitch = UISwitch()
    private let viewModel = ViewModel.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeSwitch.addTarget(self, action: #selector(changeShowFar), for: UIControl.Event.valueChanged)
        changeSwitch.isOn = viewModel.isAlwaysDarkAppearance
        accessoryView = changeSwitch
    }
    
    @objc func changeShowFar() {
        viewModel.isAlwaysDarkAppearance = changeSwitch.isOn
    }
}
