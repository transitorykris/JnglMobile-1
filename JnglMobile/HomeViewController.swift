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
    
}
