//
//  UserDefaultsExtension.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/28.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

// MARK: UserDefaultTypedKeys
extension UserDefaultTypedKeys {
    static let arrowColor = UserDefaultTypedKey<CGFloat>("arrowColorWhite")
    static let showFar = UserDefaultTypedKey<Bool>("showFar")
    
    static let date = UserDefaultTypedKey<Date>("date")
    static let lastUsed = UserDefaultTypedKey<String>("lastUsed")
    static let previousAnnotation = UserDefaultTypedKey<Bool>("previousAnnotation")
    static let usingTimes = UserDefaultTypedKey<Int>("usingTimes")
}

extension UserDefaults {
    func get<Value: UserDefaultConvertible>(_ key: UserDefaultTypedKey<Value>) -> Value? {
        guard let result = object(forKey: key.key) as? Value else { return nil }
        return result
    }
    
    func set<Value: UserDefaultConvertible>(_ value: Value, forKey key: UserDefaultTypedKey<Value>) {
        set(value, forKey: key.key)
    }
    
    func register<Value: UserDefaultConvertible>(_ value: Value, forKey key: UserDefaultTypedKey<Value>) {
        register(defaults: [key.key: value])
    }
}
