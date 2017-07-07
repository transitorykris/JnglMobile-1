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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        upspin = Upspin()
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
            print("Navigating to Settings")
            guard let settingsViewController = segue.destination as? SettingsViewController else {
                fatalError("Unexpected destination")
            }
            settingsViewController.upspin = upspin
            
        default:
            fatalError("Unknown segue identifier \(String(describing: segue.identifier))")
            
        }
        
        print("Navigating")
    }
    
    // MARK: Actions
    @IBAction func getFileButton(_ sender: UIButton) {
        var contents: Data
        
        do {
            try contents = upspin.client.get(filenameTextField.text)
        } catch let error as NSError {
            print("Failed to get file \(error)")
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
            print("Failed to get listing \(error)")
            fileContentsTextView.text = "Failed to get listing \(error)"
            return
        }
        
        var listing = ""
        var entry = dirEntry
        while entry != nil {
            print("\(String(describing: entry?.name()))")
            listing = listing + (entry?.name())! + "\n"
            entry = entry?.next()
        }
        fileContentsTextView.text = listing
    }
    
}
