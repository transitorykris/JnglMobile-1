//
//  FileViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/21/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit
import Spinner

func stripFilename (path: String) -> String {
    // Returns the path with the filename stripped off
    let components = URL(fileURLWithPath: path).pathComponents
    let root = Array(components[0 ... components.count-2])
    return NSString.path(withComponents: root)
    
}

class FileViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var openButton: UIBarButtonItem!
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    var upspin: Upspin?
    var file: SpinnerDirEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = lastPathComponent((file?.name())!)
        
        // Set up the file metadata
        filenameLabel.text = file?.name()
        lastModifiedLabel.text = String(describing: dateFrom(unixTime: (file?.lastModified())!))
        sizeLabel.text = sizeToName(bytes: (file?.size())!)
        writerLabel.text = file?.writer()
        iconImage.image = systemIcon(for: file!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Actions
    @IBAction func openButton(_ sender: Any) {
        // Download the file from upspin
        var data: Data?
        do {
            data = try upspin?.client.get(file?.name())
        } catch {
            alert(title: "Failed to download", message: error.localizedDescription)
            return
        }
        
        // Get an URL for our file
        let fileManager = FileManager.default
        let dirURL = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
        // Create the download directory, we'll mirror the path in upspin
        do {
            print("Trying to create directory at \(dirURL.path)")
            try fileManager.createDirectory(atPath: dirURL.path.appending(stripFilename(path: (file?.name())!)), withIntermediateDirectories: true, attributes: nil)
        } catch {
            alert(title: "Failed to create download directory", message: error.localizedDescription)
            return
        }
        
        // Save the file
        let fileURL = dirURL.appendingPathComponent((file?.name())!)
        print("Trying to create file at \(fileURL.path)")
        if !fileManager.createFile(atPath: fileURL.path, contents: data, attributes: nil) {
            alert(title: "Failed to create file", message: "Unknown error")
            return
        }
        
        // Present the menu for the user to choose how to open the file
        let uiDocumentInteractionController = UIDocumentInteractionController(url: fileURL)
        uiDocumentInteractionController.presentOpenInMenu(from: openButton, animated: true)
    }
    
}
