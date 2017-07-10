//
//  Keychain.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/7/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import Foundation

class Keychain: NSObject {
    
    func saveItem(item: Upspin) throws {
        let plistEncoder = PropertyListEncoder()
        let data = try plistEncoder.encode(item)
        let attributes: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrLabel: "JnglMobile",
            kSecAttrAccount: item.config.userName(),
            kSecAttrDescription: "An Upspin identity",
            kSecValueData: data,
            kSecReturnData: kCFBooleanTrue,
            ] as CFDictionary
        var addResult: AnyObject?
        let status = SecItemAdd(attributes, &addResult)
        switch status {
        case errSecDuplicateItem:
            try updateKeychainItem(item: item)
        case 0:
            // Success
            return
        default:
            // TODO: throw an exception
            fatalError("Failed to save keychain item: \(status)")
        }
    }
    
    func deleteKeychainItem() {
        // Delete the item if it exists
        let deleteQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrLabel: "JnglMobile",
            kSecMatchLimit: kSecMatchLimitAll,
            ] as CFDictionary
        let _ = SecItemDelete(deleteQuery)
        // TODO: Throw an exception
    }
    
    func updateKeychainItem(item: Upspin) throws {
        // Modify the keychain item
        let plistEncoder = PropertyListEncoder()
        plistEncoder.outputFormat = PropertyListSerialization.PropertyListFormat.xml
        let data = try plistEncoder.encode(item)
        let updateQuery: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrLabel: "JnglMobile",
            kSecAttrAccount: item.config.userName(),
            ] as CFDictionary
        let update: CFDictionary = [
            kSecValueData: data,
            ] as CFDictionary
        let status = SecItemUpdate(updateQuery, update)
        if status != noErr {
            // TODO: throw exceptions instead
            fatalError("Failed to update keychain item: \(status)")
        }
    }
    
    func getKeychainItem() -> Data? {
        // Retrieve the keychain item
        let query: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrLabel: "JnglMobile",
            kSecAttrAccount: "kris@jn.gl",
            kSecReturnData: kCFBooleanTrue,
            //kSecReturnAttributes: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne,
            ] as CFDictionary
        var queryResult: AnyObject?
        let queryStatus = SecItemCopyMatching(query, &queryResult)
        if queryStatus != noErr {
            // TODO: This should really throw an exception
            return nil
        }
        let data = queryResult as? Data
        return data
    }
    
}
