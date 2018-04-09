//
//  Edificio.swift
//  CampusAccesible
//
//  Created by Joao Gabriel Moura De Almeida on 4/9/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class Building: NSObject {
    var name : String
    var image : UIImage
    var elevator : Bool
    var schedule : String
    var bathrooms : [String]
    var coord_index : Int
    
    init(name: String, image: UIImage, elevator: Bool, schedule: String, bathrooms: [String], coord_index: Int) {
        self.name = name
        self.image = image
        self.elevator = elevator
        self.schedule = schedule
        self.bathrooms = bathrooms
        self.coord_index = coord_index
    }
}
