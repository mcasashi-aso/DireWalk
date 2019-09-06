//
//  SearchTableViewCell.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/31.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class SearchTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var directionImageView: UIImageView!
    
    var model: SearchCellModel!
    
    override func awakeFromNib() {
        
    }
    
    func setPlace(_ place: Place) {
        model = SearchCellModel(place)
        model.delegate = self
        nameLabel.text = place.placeTitle
        detailTextLabel?.text = place.address
    }
}

extension SearchTableViewCell: SearchCellModelDelegate {
    func didChangeFar() {
        let (far, unit) = model.farDescriprion
        distanceLabel.text = "\(far)\(unit)"
    }
    
    func didChangeHeading() {
        let affine
        directionImageView.
    }
}
