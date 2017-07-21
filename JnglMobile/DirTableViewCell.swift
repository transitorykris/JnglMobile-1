//
//  DirTableViewCell.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/21/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit

class DirTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var directoryNameLabel: UILabel!
    @IBOutlet weak var directoryImage: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
