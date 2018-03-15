//
//  Path.swift
//  CampusAccesible
//
//  Created by Luis Villarreal on 3/14/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class Path: NSObject {
    var coord1 : Coordinate
    var coord2 : Coordinate
    var distance : Double
    init(coord1 : Coordinate, coord2 : Coordinate) {
        self.coord1 = coord1
        self.coord2 = coord2
        let distX = coord1.lat - coord2.lat
        let distY = coord1.lon - coord2.lon
        self.distance = sqrt((distX * distX) + (distY * distY))
    }
}
