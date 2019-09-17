//
//  SearchTableViewCell.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/31.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class SearchTableViewCell: UITableViewCell, NibReusable, SearchCellModelDelegate {
    
    // MARK: - Views
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel! {
        didSet { /*didChangeFar()*/ }
    }
    @IBOutlet var directionImageView: UIImageView! {
        didSet {
            directionImageView.image = UIImage(named: "DirectionTab")
//            didChangeHeading()
        }
    }
    
    // MARK: - Model
    var model: SearchCellModel!
    
    func setPlace(_ place: Place) {
        model = SearchCellModel(place)
        model.delegate = self
        nameLabel.text = place.placeTitle
        addressLabel.text = place.address
        didChangeFar()
        didChangeHeading()
    }

    // MARK: - Model Delegate
    func didChangeFar() {
        let (far, unit) = model.farDescriprion
        distanceLabel.text = "\(far)\(unit)"
    }
    
    func didChangeHeading() {
        let affineTransform = CGAffineTransform(rotationAngle: model.heading / 180 * .pi)
        directionImageView.transform = affineTransform
    }
}
