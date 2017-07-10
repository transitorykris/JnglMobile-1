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

class Upspin: Codable {
    
    // MARK: Properties
    var config: SpinnerClientConfig!
    var client: SpinnerClient!
    
    // Blank config
    init() {
        config = SpinnerNewClientConfig()
    }
    
    // Hardcoded initialization
    init(defaults: Bool) {
        // Create a default config and client
        config = SpinnerNewClientConfig()
        config.setUserName("kris@jn.gl")
        config.setKeyNetAddr("key.upspin.io:443")
        config.setStoreNetAddr("upspin.jn.gl:443")
        config.setDirNetAddr("upspin.jn.gl:443")
        
        // Generate a hardcoded fake set of keys
        var error: NSError?
        let keys = SpinnerKeygen("lusab-babad-gutih-tugad.gutuk-bisog-mudof-sakat", &error)
        if error != nil {
            print("Error regenerating keys \(String(describing: error))")
            return
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
