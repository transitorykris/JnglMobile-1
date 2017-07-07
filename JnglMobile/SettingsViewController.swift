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
    
    var upspinConfig: SpinnerClientConfig!
    var upspinClient: SpinnerClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createConfig() {
        upspinConfig = SpinnerNewClientConfig()
        
        // Set the easy stuff
        upspinConfig.setUserName(usernameTextField.text)
        upspinConfig.setKeyNetAddr(keyServerTextField.text)
        upspinConfig.setStoreNetAddr(storeServerTextField.text)
        upspinConfig.setDirNetAddr(dirServerTextField.text)
        
        // Regenerate the public and private keys from the proquint
        var error: NSError?
        let keys = SpinnerKeygen(proquintTextField.text, &error)
        if error != nil {
            print("Error regenerating keys \(String(describing: error))")
            return
        }
        upspinConfig.setPublicKey(keys?.public())
        upspinConfig.setPrivateKey(keys?.private())
        
        print("Created configuration \(upspinConfig) public key \(upspinConfig.publicKey())")
    }
    
    func createClient() {
        var error: NSError?
        upspinClient = SpinnerNewClient(upspinConfig, &error)
        if error != nil {
            print("Error creating client \(String(describing: error))")
            return
        }
        print("Created client \(upspinClient)")
    }
    
    // Mark: Actions
    @IBAction func saveUserConfig(_ sender: UIButton) {
        print("Save user config called")
        createConfig()
        createClient()
    }
    
}

