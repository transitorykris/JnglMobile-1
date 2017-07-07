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
        config?.setUserName("kris.foster@gmail.com")
        config?.setKeyNetAddr("key.upspin.io")
        config?.setStoreNetAddr("store.jngl.io")
        config?.setDirNetAddr("dir.jngl.io")
        
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
        client = SpinnerNewClient(config, &error)
        if error != nil {
            fatalError("Could not create client \(String(describing: error))")
        }
    }
}
