//
//  HomeViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/6/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit
import Spinner

let settingsSegue:String = "Settings"

class HomeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var filenameTextField: UITextField!
    @IBOutlet weak var fileContentsTextView: UITextView!
    
    var upspin: Upspin!
    var keychain: Keychain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // So we can close the keyboard when Done is hit
        self.filenameTextField.delegate = self
        self.fileContentsTextView.delegate = self
        
        // Style the TextView to make it more obvious
        fileContentsTextView.layer.cornerRadius = 5
        fileContentsTextView.layer.borderColor = UIColor.lightGray.cgColor
        fileContentsTextView.layer.borderWidth = 1
        
        // Try to get our user's config from the Keychain and create our client
        keychain = Keychain()
        do {
            let data = try keychain.getKeychainItem()
            let propertyListDecoder = PropertyListDecoder()
            upspin = try propertyListDecoder.decode(Upspin.self, from: data!)
        } catch keychainError.failedToGet {
            // Start with a blank configuration, the user will create one next
            upspin = Upspin()
            performSegue(withIdentifier: settingsSegue, sender: nil)
        } catch {
            alert(title: "Could not create client", message: "Could not reconstruct client from the keychain configuration")
        }
    }
    
    // Close the keyboard when user presses the Done button in a text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Close the keyboard when user presses the Done button in a text view
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setDetails()
    }
    
    func setDetails() {
        if upspin == nil {
            usernameLabel.text = "Please create your settings"
            return
        }
        usernameLabel.text = upspin.config.userName()
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: false, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case settingsSegue:
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
        } catch {
            alert(title: "Failed to get file", message: "\(error)")
            return
        }
        
        if let contentsString = String(data: contents, encoding: .utf8) {
            fileContentsTextView.text = contentsString
        } else {
            alert(title: "Cannot display file", message: "Unable to convert data into a string for display")
        }
    }
    
    @IBAction func globButton(_ sender: UIButton) {
        var dirEntry: SpinnerDirEntry?
        
        do {
            try dirEntry = upspin.client.glob(filenameTextField.text)
        } catch {
            alert(title: "Cannot list files", message: "\(error)")
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
            alert(title: "Failed to put file", message: "\(error)")
            return
        }
    }
    
}
