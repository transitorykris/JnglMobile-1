//
//  FilesTableViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/20/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit
import Spinner

// Convert to Date from Upspin's int64 timestamp
func dateFrom(unixTime: Int64) -> Date {
    return Date(timeIntervalSince1970: Double(unixTime))
}

// Take a size in bytes and write out something human friendly
func sizeToName(bytes: Int64) -> String {
    if bytes < 1024 {
        return "\(bytes)B"
    } else if bytes < 1024*1024 {
        return "\(bytes/(1024))KB"
    } else if bytes < 1024*1024*1024 {
        return "\(bytes/(1024*1024))MB"
    } else if bytes < 1024*1024*1024*1024 {
        return "\(bytes/(1024*1024*1024))GB"
    } else {
        return "\(bytes/(1024*1024*1024*1024))TB"
    }
}

func systemIcon(for file: SpinnerDirEntry) -> UIImage {
    // Try to get an icon for this file
    // TODO: Get proper icons for directories and links
    let url = URL(fileURLWithPath: file.name(), isDirectory: file.isDir())
    let uiDocumentInteractionController = UIDocumentInteractionController(url: url)
    let icon = uiDocumentInteractionController.icons[0] // Take the first one, since that's guaranteed
    return icon
}

func path(_ components: [String]) -> String {
    return NSString.path(withComponents: components) as String
}

let fileSegue = "fileSegue"
let directorySegue = "directorySegue"

class FilesTableViewController: UITableViewController {
    
    // MARK: Properties
    var upspin: Upspin!
    
    // This is the directory that this view controller should show
    var dir: String?
    
    var files: [SpinnerDirEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // If dir is nil this is the root FilesTableViewController
        if dir == nil {
            dir = path([upspin.config.userName()])
        }
        
        loadFiles()
    }
    
    private func loadFiles() {
        var dirEntries: SpinnerDirEntry?
        
        do {
            dirEntries = try upspin.client.glob(path([dir!, "*"]))
        } catch {
            // TODO: This could fail if the directory is empty
            alert(title: "Problem listing directory", message: "\(error)")
        }
    
        var dirEntry = dirEntries
        while dirEntry != nil {
            files.append(dirEntry!)
            dirEntry = dirEntry?.next()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1 // or 1?
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return files.count
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: false, completion: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This tableView is called when the FileTableCellView appears on the user's screen
        // Table view cells are reused and should be dequeued using a cell identifier.
        let file = files[indexPath.row]
        
        if file.isDir() {
            return dirCell(tableView, cellForRowAt: indexPath, file: file)
        } else {
            return fileCell(tableView, cellForRowAt: indexPath, file: file)
        }
    }
    
    func fileCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, file: SpinnerDirEntry) -> UITableViewCell {
        let cellIdentifier = "FilesTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FilesTableViewCell else {
            fatalError("The dequeued cell is not an instance of FilesTableViewCell")
        }
        
        // Configure the cell...
        cell.filenameLabel.text = file.name()
        cell.lastmodifiedLabel.text = String(describing: dateFrom(unixTime: file.lastModified()))
        cell.sizeLabel.text = sizeToName(bytes: file.size())
        cell.iconImage.image = systemIcon(for: file)
        
        return cell
    }
    
    func dirCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, file: SpinnerDirEntry) -> UITableViewCell {
        let cellIdentifier = "DirTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DirTableViewCell else {
            fatalError("The dequeued cell is not an instance of DirTableViewCell")
        }
        
        // Configure the cell...
        cell.directoryNameLabel.text = file.name()
        cell.directoryImage.image = systemIcon(for: file)
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case fileSegue:
            print("Not implemented: fileSegue")
            
        case directorySegue:
            guard let filesTableViewController = segue.destination as? FilesTableViewController else {
                fatalError("Failed to create dirTableViewCell")
            }
            let dirCell = sender as? DirTableViewCell
            filesTableViewController.upspin = upspin
            let dirName = (dirCell?.directoryNameLabel.text)!
            filesTableViewController.dir = dirName
            
        default:
            fatalError("Unknown segue identifier \(String(describing: segue.identifier))")
            
        }
    }

}
