//
//  UserDefaultsWrapper.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

protocol UserDefaultConvertible {
    init?(with object: Any)
    func object() -> Any?
}

extension UserDefaultConvertible where Self: Codable {
    init?(with object: Any) {
        guard let data = object as? Data,
            let value = try? JSONDecoder().decode(Self.self, from: data) else {
                return nil
        }
        self = value
    }
    
    func object() -> Any? {
        return try? JSONEncoder().encode(self)
    }
}

@propertyWrapper
struct UserDefault<Value: UserDefaultConvertible> {
    let typedKey: UserDefaultTypedKey<Value>
    let defaultValue: Value
    
    init(_ typedKey: UserDefaultTypedKey<Value>, defaultValue: Value) {
        self.typedKey = typedKey
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Value {
        get {
            if let object = UserDefaults.standard.object(forKey: typedKey.key),
                let value = Value(with: object) {
                return value
            }else {
                return self.defaultValue
            }
        }
        set {
            if let object = newValue.object() {
                UserDefaults.standard.set(object, forKey: typedKey.key)
            }else {
                UserDefaults.standard.removeObject(forKey: typedKey.key)
            }
        }
    }
}

class UserDefaultTypedKeys {
    init() {}
}

class UserDefaultTypedKey<T: UserDefaultConvertible>: UserDefaultTypedKeys {
    let key: String
    init(_ key: String) {
        self.key = key
        super.init()
    }
}
