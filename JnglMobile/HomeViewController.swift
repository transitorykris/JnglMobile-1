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
    
    // MARK: Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var filenameTextField: UITextField!
    @IBOutlet weak var fileContentsTextView: UITextView!
    
    var upspin: Upspin!
    var keychain: Keychain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the TextView to make it more obvious
        fileContentsTextView.layer.cornerRadius = 5
        fileContentsTextView.layer.borderColor = UIColor.lightGray.cgColor
        fileContentsTextView.layer.borderWidth = 1
        
        // Try to get our user's config from the Keychain
        keychain = Keychain()
        let data = keychain.getKeychainItem()
        if data == nil {
            // TODO: Send them to settings
            fatalError("No config found in keychain")
        }
        
        // Create an upspin client with this config
        let propertyListDecoder = PropertyListDecoder()
        do {
            upspin = try propertyListDecoder.decode(Upspin.self, from: data!)
        } catch {
            fatalError("Could not reconstruct config and client")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setDetails()
    }
    
    func setDetails() {
        usernameLabel.text = upspin.config.userName()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "Settings":
            guard let settingsViewController = segue.destination as? SettingsViewController else {
                fatalError("Unexpected destination")
            }
            settingsViewController.upspin = upspin
            settingsViewController.keychain = keychain
            
        default:
            fatalError("Unknown segue identifier \(String(describing: segue.identifier))")
            
        }
    }
    
    // MARK: Actions
    @IBAction func getFileButton(_ sender: UIButton) {
        var contents: Data
        
        do {
            try contents = upspin.client.get(filenameTextField.text)
        } catch let error as NSError {
            fileContentsTextView.text = "Failed to get file \(error)"
            return
        }
        
        if let contentsString = String(data: contents, encoding: .utf8) {
            fileContentsTextView.text = contentsString
        } else {
            fileContentsTextView.text = "Failed to convert data to string"
        }
    }
    
    @IBAction func globButton(_ sender: UIButton) {
        var dirEntry: SpinnerDirEntry?
        
        do {
            try dirEntry = upspin.client.glob(filenameTextField.text)
        } catch let error as NSError {
            fileContentsTextView.text = "Failed to get listing \(error)"
            return
        }
        
        var listing = ""
        var entry = dirEntry
        while entry != nil {
            listing = listing + (entry?.name())! + "\n"
            entry = entry?.next()
        }
        fileContentsTextView.text = listing
    }
    
    @IBAction func putButton(_ sender: UIButton) {
        do {
            try upspin.client.put(filenameTextField.text, data: fileContentsTextView.text.data(using: String.Encoding.utf8))
        } catch {
            // TODO: let the user know something went wrong
            return
        }
    }
    
}
