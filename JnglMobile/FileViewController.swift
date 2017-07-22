//
//  FileViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/21/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit
import Spinner

class FileViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var openButton: UIBarButtonItem!
    
    var file: SpinnerDirEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = lastPathComponent((file?.name())!)
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
    
    // MARK: Actions
    @IBAction func openButton(_ sender: Any) {
        let url = URL(fileURLWithPath: "test.png")
        let uiDocumentInteractionController = UIDocumentInteractionController(url: url)
        uiDocumentInteractionController.presentOpenInMenu(from: openButton, animated: true)
    }
    
}
