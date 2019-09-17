//
//  MySlider.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class SliderTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: TappableSlider!
    var didChange: ((Float) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slider.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
    }
    
    
    
    func setup(title: String,
               initialValue: Float,
               didChange: @escaping (Float) -> Void) {
        titleLabel.text = title
        slider.value = initialValue
        self.didChange = didChange
    }
    
    @objc func changeValue(_ sender: TappableSlider) {
        guard let f = didChange else { return }
        f(sender.value)
    }
}

class TappableSlider: UISlider {
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = super.trackRect(forBounds: bounds)
        bounds.size.height = 12
        return bounds
    }
    
}
