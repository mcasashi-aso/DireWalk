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
            if let object = UserDefaults.standard.object(forKey: self.typedKey.key),
                let value = Value(with: object) {
                return value
            }else {
                return self.defaultValue
            }
        }
        set {
            if let object = newValue.object() {
                UserDefaults.standard.set(object, forKey: self.typedKey.key)
            }else {
                UserDefaults.standard.removeObject(forKey: self.typedKey.key)
            }
        }
    }
}

class UserDefaultTypedKeys {
    init() {}
}

class UserDefaultTypedKey<T>: UserDefaultTypedKeys {
    let key: String
    init(_ key: String) {
        self.key = key
        super.init()
    }
}

// MARK: 以下に適合したい型を書く

extension Int: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? Int else { return nil }
        self = value
    }
    func object() -> Any? { return self }
}

extension String: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? String else { return nil }
        self = value
    }
    func object() -> Any? { self }
}

extension Optional: UserDefaultConvertible where Wrapped: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = Wrapped(with: object) else { return nil }
        self = .some(value)
    }
    func object() -> Any? {
        switch self {
        case .some(let value): return value.object()
        case .none: return .none
        }
    }
}

extension Array: UserDefaultConvertible where Element: UserDefaultConvertible {
    private struct Error: Swift.Error {}
    
    init?(with object: Any) {
        guard let array = object as? [Any] else { return nil }
        guard let value = try? array.map({ (object) -> Element in
            if let element = Element(with: object) {
                return element
            }else {
                throw Error()
            }
        }) else { return nil }
        
        self = value
    }
    
    func object() -> Any? {
        return try? self.map { (element) -> Any in
            if let object = element.object() {
                return object
            }else {
                throw Error()
            }
        }
    }
}

extension Place: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? Place else { return nil }
        self = value
    }
    func object() -> Any? { self }
}

extension Date: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? Date else { return nil }
        self = value
    }
    func object() -> Any? { self }
}

extension Bool: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? Bool else { return nil }
        self = value
    }
    func object() -> Any? { self }
}

extension CGFloat: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? CGFloat else { return nil }
        self = value
    }
    func object() -> Any? { self }
}
