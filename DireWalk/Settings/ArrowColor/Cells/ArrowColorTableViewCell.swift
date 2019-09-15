//
//  MySlider.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

protocol ArrowColorTableViewCellDelegate: class {
    func didChangeArrowColor(_ whiteValue: CGFloat)
}
final class ArrowColorTableViewCell: UITableViewCell {
    @IBOutlet weak var slider: TappableSlider!
    private var settings = Settings.shared
    weak var delegate: ArrowColorTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let arrowColor = settings.arrowColor
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = Float(arrowColor)
        slider.minimumTrackTintColor = UIColor.black
        slider.maximumTrackTintColor = UIColor.white
        slider.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
    }
    
    @objc func changeValue(_ sender: TappableSlider) {
        delegate?.didChangeArrowColor(CGFloat(sender.value))
    }
}


final class TappableSlider: UISlider {
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = super.trackRect(forBounds: bounds)
        bounds.size.height = 12
        return bounds
    }
    
}
