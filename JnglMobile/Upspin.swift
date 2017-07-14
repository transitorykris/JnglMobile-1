//
//  Upspin.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/6/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import Foundation
import Security
import Spinner

enum clientError: Error {
    case createClient
}

enum CodingKeys: String, CodingKey {
    case userName
    case keyNetAddr
    case storeNetAddr
    case dirNetAddr
    case publicKey
    case privateKey
}

func UpspinClientFromKeychain() throws -> Upspin {
    // Try to get our user's config from the Keychain and create our client
    let keychain = Keychain()
    let data = try keychain.getKeychainItem()
    
    // Recreate our upspin client object
    let propertyListDecoder = PropertyListDecoder()
    let upspin = try propertyListDecoder.decode(Upspin.self, from: data!)
    return upspin
}


class Upspin: Codable {
    
    // MARK: Properties
    var config: SpinnerClientConfig!
    var client: SpinnerClient!
    
    // Blank config
    init() {
        config = SpinnerNewClientConfig()
    }
    
    // Hardcoded initialization
    init(userName: String, keyNetAddr: String, storeNetAddr: String, dirNetAddr: String, proquint: String) {
        config = SpinnerNewClientConfig()
        config.setUserName(userName)
        config.setKeyNetAddr(keyNetAddr)
        config.setStoreNetAddr(storeNetAddr)
        config.setDirNetAddr(dirNetAddr)
        
        var error: NSError?
        let keys = SpinnerKeygen(proquint, &error)
        if error != nil {
            fatalError("Error regenerating keys \(String(describing: error))")
        }
        config.setPublicKey(keys?.public())
        config.setPrivateKey(keys?.private())
        
        do {
            try createUpspinClient()
        } catch {
            fatalError("Failed to create client")
        }
    }
    
    // init is used to construct this object from a config saved in the keychain
    required init(from decoder: Decoder) throws {
        config = SpinnerNewClientConfig()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try config.setUserName(values.decode(String.self, forKey: .userName))
        try config.setKeyNetAddr(values.decode(String.self, forKey: .keyNetAddr))
        try config.setStoreNetAddr(values.decode(String.self, forKey: .storeNetAddr))
        try config.setDirNetAddr(values.decode(String.self, forKey: .dirNetAddr))
        try config.setPublicKey(values.decode(String.self, forKey: .publicKey))
        try config.setPrivateKey(values.decode(String.self, forKey: .privateKey))
        
        try createUpspinClient()
    }
    
    // encode serializes the configuration for saving in the keychain
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(config.userName(), forKey: .userName)
        try container.encode(config.keyNetAddr(), forKey: .keyNetAddr)
        try container.encode(config.storeNetAddr(), forKey: .storeNetAddr)
        try container.encode(config.dirNetAddr(), forKey: .dirNetAddr)
        try container.encode(config.publicKey(), forKey: .publicKey)
        try container.encode(config.privateKey(), forKey: .privateKey)
    }
    
    func createUpspinClient() throws {
        var error: NSError?
        client = SpinnerNewClient(config, &error)
        if error != nil {
            throw clientError.createClient
        }
    }
    
}
