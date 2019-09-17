//
//  ArrowViewTableViewCells.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/14.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class SegmentedTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.removeAllSegments()
            segmentedControl.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        }
    }
    var didChange: ((Int) -> Void)?
    
    func setup(title: String, array: [String], initialValue: String,
               didChange: @escaping (Int) -> Void) {
        titleLabel.text = title
        for (index, value) in array.enumerated() {
            segmentedControl.insertSegment(withTitle: value, at: index, animated: false)
            if value == initialValue {
                segmentedControl.selectedSegmentIndex = index
            }
        }
        self.didChange = didChange
    }
    
    @objc func valueChanged(_ sender: UISegmentedControl) {
        guard let f = didChange else { return }
        f(sender.selectedSegmentIndex)
    }
}
