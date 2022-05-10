//
//  UserDefaults+Extensions.swift
//  VMTools
//
//  Created by Rynaard Burger on 2022/05/10.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

extension UserDefaults {
    @UserDefault(key: "vm_search_path", defaultValue: "/Users/rynaardburger/VMs")
    static var vmSearchPath: String
}
