//
//  MakeDirectoryViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/21/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit

class MakeDirectoryViewController: UIViewController {
    
    var upspin: Upspin?
    var baseDir: String?
    
    // MARK: Properties
    @IBOutlet weak var directoryNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: false, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createButton(_ sender: Any) {
        let newDir = path([baseDir!, directoryNameField.text!])
        
        do {
            try upspin?.client.makeDirectory(newDir)
        } catch {
            // TODO: Fix this, it doesn't work
            alert(title: "Failed to make directory", message: error.localizedDescription)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
