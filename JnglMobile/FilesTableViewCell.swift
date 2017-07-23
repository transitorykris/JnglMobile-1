//
//  FilesTableViewCell.swift
//  JnglMobile
//
//  Created by Kris Foster on 7/20/17.
//  Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
//

import UIKit

class FilesTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var lastmodifiedLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var writerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if !selected {
            return // Nothing to do here
        }
    }

}
