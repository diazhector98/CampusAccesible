//
//  CustomTableViewCell.swift
//  CampusAccesible
//
//  Created by Arturo González on 4/8/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgBuilding: UIImageView!
    @IBOutlet weak var lbBuildingName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
