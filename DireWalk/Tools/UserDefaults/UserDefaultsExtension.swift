//
//  UserDefaultsExtension.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/28.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

extension UserDefaults {
    func get<Value: UserDefaultConvertible>(_ typedKey: UserDefaultTypedKey<Value>) -> Value? {
        guard let object = object(forKey: typedKey.key),
            let value = Value(with: object) else { return nil }
        return value
    }
    
    func set<Value: UserDefaultConvertible>(_ value: Value, forKey typedKey: UserDefaultTypedKey<Value>) {
        if let object = value.object() {
            set(object, forKey: typedKey.key)
        }else {
            removeSuite(named: typedKey.key)
        }
    }
    
    func register<Value: UserDefaultConvertible>(_ value: Value, forKey typedKey: UserDefaultTypedKey<Value>) {
        guard let object = value.object() else { return }
        register(defaults: [typedKey.key: object])
    }
}


class Boss {}
class Box<T>: Boss {
    let val: T
    init(_ v: T) { self.val = v }
}
extension Box where T: Equatable {
    static func ==(lhs: Box<T>, rhs: Box<T>) -> Bool {
        lhs.val == rhs.val
    }
}
extension Boss {
    static let non = Box<Int>(3)
    static let op = Box<Int?>(3)
}
class Manager {
    func a<T>(_ value: T, _ cl: Box<T>) {}
    func b<T>(_ a: T, _ b: T) {}
    func c<T: Equatable>(_ a: Box<T>, _ b: Box<T>) -> T {
        a == b ? a.val : b.val
    }
}

class Test {
    func test() {
        let manager = Manager()
        manager.a(3, .non)
        manager.a(3, .op)
        manager.b(Optional(3), 4)
        let t: Int = manager.c(.non, .op)
        let place = Place(latitude: 0, longitude: 0, placeTitle: "", adress: "")
        UserDefaults.standard.set(place, forKey: .place)
    }
}
