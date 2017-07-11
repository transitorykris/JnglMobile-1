//
//  page3ViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/11/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit

class page3ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    @IBAction func setupButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NavigationController")
        self.present(viewController, animated: true)
    }
    
}
