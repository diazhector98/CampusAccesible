//
//  Coordinate.swift
//  CampusAccesible
//
//  Created by Luis Villarreal on 3/14/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class Coordinate: NSObject {
    var lat : Double
    var lon : Double
    var index : Int
    
    init(lat: Double, lon: Double, index: Int) {
        self.lat = lat
        self.lon = lon
        self.index = index
    }
}
