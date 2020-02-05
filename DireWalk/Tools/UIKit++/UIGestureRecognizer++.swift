//
//  UIGestureRecognizer++.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/12/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

extension UIGestureRecognizer.State: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .possible:   return "possible"
        case .began:      return "began"
        case .changed:    return "changed"
        case .ended:      return "ended"
        case .cancelled:  return "cancelled"
        case .failed:     return "failed"
        @unknown default: return "unknown"
        }
    }
}
