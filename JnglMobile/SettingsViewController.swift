//
//  ViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/5/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit
import Spinner

enum saveConfigError: Error {
    case invalidProquint
    case keychainSaveFailed
}

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var proquintTextField: UITextField!
    @IBOutlet weak var keyServerTextField: UITextField!
    @IBOutlet weak var storeServerTextField: UITextField!
    @IBOutlet weak var dirServerTextField: UITextField!
    
    var upspin: Upspin!
    var keychain: Keychain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // So we can control the keyboard
        self.usernameTextField.delegate = self
        self.proquintTextField.delegate = self
        self.keyServerTextField.delegate = self
        self.storeServerTextField.delegate = self
        self.dirServerTextField.delegate = self
        
        // Populate our form if details were given to us
        if let upspin = upspin {
            usernameTextField.text = upspin.config.userName()
            keyServerTextField.text = upspin.config.keyNetAddr()
            storeServerTextField.text = upspin.config.storeNetAddr()
            dirServerTextField.text = upspin.config.dirNetAddr()
        }
    }
    
    // Close the keyboard when user presses the Done button
    // TODO: Make this a Next button and move to the next field instead?
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: false, completion: nil)
    }
    
    func saveConfig() throws {
        // Set the easy stuff
        upspin.config.setUserName(usernameTextField.text)
        upspin.config.setKeyNetAddr(keyServerTextField.text)
        upspin.config.setStoreNetAddr(storeServerTextField.text)
        upspin.config.setDirNetAddr(dirServerTextField.text)
        
        // Regenerate the public and private keys from the proquint if we got one
        if proquintTextField.text != "" {
            var error: NSError?
            let keys = SpinnerKeygen(proquintTextField.text, &error)
            if error != nil {
                throw saveConfigError.invalidProquint
            }
            upspin.config.setPublicKey(keys?.public())
            upspin.config.setPrivateKey(keys?.private())
        }
        
        try upspin.createUpspinClient()
        
        // Save to the keychain
        do {
            try keychain.saveItem(item: upspin)
        } catch {
            throw saveConfigError.keychainSaveFailed
        }
    }
    
    // Mark: Actions
    @IBAction func saveUserConfig(_ sender: UIButton) {
        do {
            try saveConfig()
        } catch saveConfigError.invalidProquint {
            alert(title: "Failed to save", message: "The supplied proquint could not be used to regenerate your keys")
        } catch saveConfigError.keychainSaveFailed {
            alert(title: "Failed to save", message: "Problem saving your configuration to the keychain")
        } catch {
            alert(title: "Failed to save", message: "An unknown error occured while saving")
        }
        
        // Now send them back home
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NavigationController")
        self.present(viewController, animated: true)
    }
    
}

