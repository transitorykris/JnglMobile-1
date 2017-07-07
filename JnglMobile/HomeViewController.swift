//
//  HomeViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/6/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit
import Spinner

class HomeViewController: UIViewController {
    
    var upspinConfig: SpinnerClientConfig!
    var upspinClient: SpinnerClient!
    
    func loadUpspinConfig() {
        // Hardcode our config for now
        upspinConfig = SpinnerNewClientConfig()
        upspinConfig?.setUserName("kris.foster@gmail.com")
        upspinConfig?.setKeyNetAddr("key.upspin.io")
        upspinConfig?.setStoreNetAddr("store.jngl.io")
        upspinConfig?.setDirNetAddr("dir.jngl.io")
        
        // Generate a hardcoded fake set of keys
        var error: NSError?
        let keys = SpinnerKeygen("lusab-babad-gutih-tugad.gutuk-bisog-mudof-sakat", &error)
        if error != nil {
            print("Error regenerating keys \(String(describing: error))")
            return
        }
        upspinConfig.setPublicKey(keys?.public())
        upspinConfig.setPrivateKey(keys?.private())
    }
    
    func createUpspinClient() {
        var error: NSError?
        upspinClient = SpinnerNewClient(upspinConfig, &error)
        if error != nil {
            fatalError("Could not create client \(String(describing: error))")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUpspinConfig()
        createUpspinClient()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "Settings":
            print("Navigating to Settings")
            guard let settingsViewController = segue.destination as? SettingsViewController else {
                fatalError("Unexpected destination")
            }
            settingsViewController.upspinConfig = upspinConfig
            
        default:
            print("Navigating to who knows where \(String(describing: segue.identifier))")
            
        }
        
        print("Navigating")
    }
    
}
