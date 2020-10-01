//
//  KeyChainWrapper.swift
//  Walayem
//
//  Created by ITRS-348 on 08/07/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import KeychainSwift

struct KeychainKeys {
    
    static let USER_EMAIL = "email"
    static let USER_FIRSTNAME = "firstname"
    static let USER_LASTNAME = "lastname"
    static let USER_KEY = "key"
    
}

class KeyChainWrapper {
    
    static var shared: KeyChainWrapper?
    
    static func setKeychainWrapper() {
        if KeyChainWrapper.shared == nil {
            KeyChainWrapper.shared = KeyChainWrapper()
        }
    }
    
    private init() {}
    
    func initializeKeychain() -> KeychainSwift {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        return keychain
    }
    
    func setKeychainValue(key: String, value: String) {
        initializeKeychain().set(value, forKey: key)
    }
    
    func setKeychainValue(key: String, value: Bool) {
        initializeKeychain().set(value, forKey: key)
    }
    
    func getValue(key: String) -> String {
        return initializeKeychain().get(key) ?? ""
    }
    
    func getValue(key: String) -> Bool {
        return initializeKeychain().getBool(key) ?? false
    }
    
    func deleteKeychain() {
        initializeKeychain().clear()
    }
    
    
}
