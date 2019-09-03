//
//  SearchTableViewCell.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/31.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class SearchTableViewCell: UITableViewCell {
    @objc let favoriteButton = UIButton()
    var place: Place!
    
    override func awakeFromNib() {
        favoriteButton.addTarget(self, action: #selector(tapFavorite), for: .touchUpInside)
        favoriteButton.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        if #available(iOS 13, *) {
            let image = UIImage(systemName: "heart.fill")!
            favoriteButton.setImage(image, for: .normal)
        }else {
            let image = UIImage(named: "HeartFill")!.withRenderingMode(.alwaysTemplate)
            favoriteButton.setImage(image, for: .normal)
            favoriteButton.tintColor = .systemBlue
        }
        accessoryView = favoriteButton
    }
    
    func setPlace(_ place: Place) {
        self.place = place
        textLabel?.text = place.placeTitle
        detailTextLabel?.text = place.address
        favoriteButton.isHidden = !place.isFavorite
    }
    
    @objc func tapFavorite() {
        place.isFavorite.toggle()
        favoriteButton.isHidden = !place.isFavorite
    }
}
