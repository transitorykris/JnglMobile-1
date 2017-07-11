//
//  Keychain.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/7/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import Foundation

enum keychainError: Error {
    case failedToSave
    case failedToDelete
    case failedToUpdate
    case failedToGet
}

let keychainAccessGroupName = "7UXE8T6JQ7.co.aheadbyacentury.JnglMobile"

class Keychain: NSObject {
    
    func saveItem(item: Upspin) throws {
        let encoder = PropertyListEncoder()
        let data = try encoder.encode(item)
        let attributes: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessGroup: keychainAccessGroupName,
            kSecAttrAccount: item.config.userName(),
            kSecValueData: data,
            ] as CFDictionary
        var result: AnyObject?
        let status = SecItemAdd(attributes, &result)
        switch status {
        case noErr:
            return
        case errSecDuplicateItem:
            try updateKeychainItem(item: item)
        default:
            throw keychainError.failedToSave
        }
    }
    
    func deleteAllKeychainItems() throws {
        // Delete the item if it exists
        let query: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessGroup: keychainAccessGroupName,
            kSecMatchLimit: kSecMatchLimitAll,
            ] as CFDictionary
        let status = SecItemDelete(query)
        if status != noErr {
            throw keychainError.failedToUpdate
        }
    }
    
    func updateKeychainItem(item: Upspin) throws {
        // Modify the keychain item
        let encoder = PropertyListEncoder()
        encoder.outputFormat = PropertyListSerialization.PropertyListFormat.xml
        let data = try encoder.encode(item)
        let query: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: item.config.userName(),
            ] as CFDictionary
        let update: CFDictionary = [
            kSecAttrAccessGroup: keychainAccessGroupName,
            kSecValueData: data,
            ] as CFDictionary
        let status = SecItemUpdate(query, update)
        if status != noErr {
            throw keychainError.failedToUpdate
        }
    }
    
    // For now we assume there's just one account configured
    func getKeychainItem() throws -> Data? {
        // Retrieve the keychain item
        let query: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessGroup: keychainAccessGroupName,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne,
            ] as CFDictionary
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        if status != noErr {
            throw keychainError.failedToGet
        }
        let data = result as? Data
        return data
    }
    
}
