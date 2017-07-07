//
//  Upspin.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/6/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import Foundation
import Spinner

class Upspin: NSObject {
    
    // MARK: Properties
    var config: SpinnerClientConfig!
    var client: SpinnerClient!
    
    // Hardcoded initialization
    override init() {
        super.init()
        
        loadUpspinConfig()
        createUpspinClient()
    }
    
    func loadUpspinConfig() {
        // Hardcode our config for now
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
    }
    
    func createUpspinClient() {
        var error: NSError?
        print("Using config \(config)")
        client = SpinnerNewClient(config, &error)
        if error != nil {
            fatalError("Could not create client \(String(describing: error))")
        }
        print("Client created")
    }
    
}
