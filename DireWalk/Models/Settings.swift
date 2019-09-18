//
//  Settings.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/06.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class Settings {
    
    static let shared = Settings()
    private init() {}
    
    public enum ArrowImage: String, Codable, CaseIterable, UserDefaultConvertible {
        case fillLocation = "fillLocation"
        case location = "borderLocation"
        
        var name: String { self.rawValue.localized }
        
        var image: UIImage {
            switch self {
            case .fillLocation:
                if #available(iOS 13, *) {
                    return UIImage(systemName: "location.north.fill")!
                }else {
                    return UIImage(named: "Direction")!
                }
            case .location:
                if #available(iOS 13, *) {
                    let config = UIImage.SymbolConfiguration(weight: .light)
                    return UIImage(systemName: "location.north", withConfiguration: config)!
                }else {
                    return UIImage(named: "Direction")!
                }
            }
        }
    }
    
    @UserDefault(.arrowImageName, defaultValue: .fillLocation)
    var arrowImage: ArrowImage
    @UserDefault(.arrowColor, defaultValue: 0.75)
    var arrowColor: CGFloat
    @UserDefault(.showFar, defaultValue: true)
    var showFar: Bool
    @UserDefault(.isAlwaysDarkAppearance, defaultValue: true)
    var isAlwaysDarkAppearance: Bool
    
}
