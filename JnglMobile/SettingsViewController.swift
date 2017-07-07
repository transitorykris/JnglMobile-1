//
//  ViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/5/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit
import Spinner

class SettingsViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var proquintTextField: UITextField!
    @IBOutlet weak var keyServerTextField: UITextField!
    @IBOutlet weak var storeServerTextField: UITextField!
    @IBOutlet weak var dirServerTextField: UITextField!
    
    var upspin: Upspin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate our form if details were given to us
        if let upspin = upspin {
            usernameTextField.text = upspin.config.userName()
            keyServerTextField.text = upspin.config.keyNetAddr()
            storeServerTextField.text = upspin.config.storeNetAddr()
            dirServerTextField.text = upspin.config.dirNetAddr()
        }
    }
    
    func saveConfig() {
        // Set the easy stuff
        upspin.config.setUserName(usernameTextField.text)
        upspin.config.setKeyNetAddr(keyServerTextField.text)
        upspin.config.setStoreNetAddr(storeServerTextField.text)
        upspin.config.setDirNetAddr(dirServerTextField.text)
        
        // Regenerate the public and private keys from the proquint
        var error: NSError?
        let keys = SpinnerKeygen(proquintTextField.text, &error)
        if error != nil {
            print("Error regenerating keys \(String(describing: error))")
            return
        }
        upspin.config.setPublicKey(keys?.public())
        upspin.config.setPrivateKey(keys?.private())
        
        print("Created configuration \(upspin.config) public key \(upspin.config.publicKey()) private key \(upspin.config.privateKey())")
    }
    
    // Mark: Actions
    @IBAction func saveUserConfig(_ sender: UIButton) {
        print("Save user config called")
        saveConfig()
    }
    
}

