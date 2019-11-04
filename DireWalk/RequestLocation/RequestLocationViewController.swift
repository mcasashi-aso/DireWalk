//
//  ReauestLocationViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/10.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import CoreLocation

final class RequestLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Views
    @IBOutlet weak var openButton: UIButton! {
        didSet {
            if #available(iOS 13, *) {
                self.openButton.layer.cornerCurve = .continuous
            }
            self.openButton.layer.cornerRadius = 15
            // TODO: Boldにしたい
            self.openButton.setTitle("RequestVC_openSettings".localized, for: .normal)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet { self.titleLabel.text = "RequestVC_pleaseAllowLocation".localized }
    }
    
    // MARK: Text Views
    @IBOutlet weak var firstTextView: UITextView! {
        didSet {
            self.firstTextView.contentInset = .zero
            self.firstTextView.text = "RequestVC_firstText".localized
            self.firstTextView.font = .preferredFont(forTextStyle: .title2)
        }
    }
    @IBOutlet weak var secondTextView: UITextView! {
        didSet {
            self.secondTextView.contentInset = .zero
            self.secondTextView.text = "RequestVC_secondText".localized
            self.secondTextView.font = .preferredFont(forTextStyle: .title2)
        }
    }
    @IBOutlet weak var thirdTextView: UITextView! {
        didSet {
            self.thirdTextView.contentInset = .zero
            self.thirdTextView.text = "RequestVC_thirdText".localized
            self.thirdTextView.font = .preferredFont(forTextStyle: .title2)
        }
    }
    
    // MARK: Images
    @IBOutlet weak var iconImage: UIImageView! {
        didSet {
            if #available(iOS 13.0, *) {
                self.iconImage.layer.cornerCurve = .continuous
            }
            self.iconImage.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var locationImageView: UIImageView! {
        didSet {
            if #available(iOS 13, *) {
                self.locationImageView.image = UIImage(systemName: "location.fill")
            } else {
                let image = UIImage(named: "DirectionFill")?.withRenderingMode(.alwaysTemplate)
                self.locationImageView.image = image
                self.locationImageView.tintColor = .white
            }
        }
    }
    
    
    // MARK: - Action
    @IBAction func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
