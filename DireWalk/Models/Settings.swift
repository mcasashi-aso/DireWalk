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
    
    public enum ArrowImage: String, CaseIterable, Codable, UserDefaultConvertible {
        case fillLocation, location
        
        var name: String {
            switch self {
            case .fillLocation:
                if #available(iOS 13, *) {
                    return "location.north.fill"
                }else {
                    return "Direction"
                }
            case .location:
                if #available(iOS 13, *) {
                    return "location.north"
                }else {
                    return "Direction"
                }
            }
        }
        
        var image: UIImage {
            if #available(iOS 13, *) {
                return UIImage(systemName: name)!
            }else {
                return UIImage(named: name)!
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
