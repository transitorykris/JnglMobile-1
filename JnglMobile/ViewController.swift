//
//  ViewController.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/5/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit
import Spinner

class ViewController: UIViewController {
    
    var upspinConfig: SpinnerClientConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupClient() {
        upspinConfig = SpinnerNewClientConfig()
    }

}

