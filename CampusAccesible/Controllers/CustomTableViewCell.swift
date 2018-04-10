//
//  CustomTableViewCell.swift
//  CampusAccesible
//
//  Created by Arturo González on 4/8/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgCell: UIImageView!
    @IBOutlet weak var lbCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgCell.layer.borderWidth = 0
        imgCell.layer.masksToBounds = false
        imgCell.layer.cornerRadius = imgCell.frame.width / 2
        imgCell.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
