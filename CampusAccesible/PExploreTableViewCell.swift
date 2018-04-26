//
//  PExploreTableViewCell.swift
//  CampusAccesible
//
//  Created by Arturo González on 4/26/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class PExploreTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
