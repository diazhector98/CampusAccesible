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
    
    static func loadCoordinateArray() -> [Coordinate] {
        var locations = [Coordinate]()
        let locationsPath = Bundle.main.path(forResource: "Coords", ofType: "plist")
        let locationsNSArray = NSArray(contentsOfFile: locationsPath!)
        for (index, location) in locationsNSArray!.enumerated() {
            let castLocation = location as! NSDictionary
            locations.append(Coordinate(lat: castLocation.value(forKey: "longitud") as! Double, lon: castLocation.value(forKey: "latitud") as! Double, index: index))
        }
        return locations
    }
}
