//
//  ArrowViewTableViewCells.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/14.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

protocol ArrowImageStyleTableViewCellDelegate: class {
    func didChangeArrowImageStyle(_ style: Settings.ArrowImage)
}
final class ArrowImageStyleTableViewCell: UITableViewCell {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var settings = Settings.shared
    weak var delegate: ArrowImageStyleTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        
        let allImageType = Settings.ArrowImage.allCases
        for (index, imageType) in allImageType.enumerated() {
            let imageName = imageType.name
            segmentedControl.insertSegment(with: UIImage(named: imageName), at: index, animated: false)
            if imageType == settings.arrowImage {
                segmentedControl.selectedSegmentIndex = index
            }
        }
    }
    
    @objc func valueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let style = Settings.ArrowImage.allCases[index]
        delegate?.didChangeArrowImageStyle(style)
    }
}
