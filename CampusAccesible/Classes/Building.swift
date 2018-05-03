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
    var bathrooms : [NSDictionary]
    var coord_index : [Int]
    var show : Bool
    
    init(name: String, image: UIImage, elevator: Bool, schedule: String, bathrooms: [NSDictionary], coord_index: [Int], show: Bool) {
        self.name = name
        self.image = image
        self.elevator = elevator
        self.schedule = schedule
        self.bathrooms = bathrooms
        self.coord_index = coord_index
        self.show = show
    }
    
    static func loadBuildingMap() -> [String: Building] {
        var buildings = [String : Building]()
        let buildingsPath = Bundle.main.path(forResource: "ListaEdificios", ofType: "plist")
        let buildingsNSArray = NSArray(contentsOfFile: buildingsPath!)
        for building in buildingsNSArray! {
            let castBuilding = building as! NSDictionary
            buildings[castBuilding.value(forKey: "nombre") as! String] = (Building(name: castBuilding.value(forKey: "nombre") as! String, image: UIImage(named: castBuilding.value(forKey: "imagen") as! String)!, elevator: (castBuilding.allKeys as! [String]).contains("elevador") ? (castBuilding.value(forKey: "elevador") as! Bool) : false, schedule: castBuilding.value(forKey: "horario") as! String, bathrooms: castBuilding.value(forKey: "banos") as! [NSDictionary], coord_index: castBuilding.value(forKey: "coord") as! [Int], show: castBuilding.value(forKey: "show") as! Bool))
        }
        return buildings
    }
}
