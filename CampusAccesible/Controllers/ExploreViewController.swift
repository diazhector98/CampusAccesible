//
//  FirstViewController.swift
//  CampusAccesible
//
//  Created by Joao Gabriel Moura De Almeida on 3/14/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController {
    
    @IBOutlet weak var imgBuilding: UIImageView!
    @IBOutlet weak var lbSchedule: UILabel!
    @IBOutlet weak var imgSchedule: UIImageView!
    @IBOutlet weak var imgElevator: UIImageView!
    @IBOutlet weak var imgBathrooms: UIImageView!
    
    var buildingImage : String!
    var schedule : String!
    var elevator : Bool!
    var bathrooms : NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        imgSchedule.image = #imageLiteral(resourceName: "clock")
        
        imgBuilding.image = UIImage(named: buildingImage)
        lbSchedule.text = schedule
        
        if elevator {
            imgElevator.image = #imageLiteral(resourceName: "check")
        } else {
            imgElevator.image = #imageLiteral(resourceName: "cross")
        }
        
        if bathrooms.count > 0 {
            imgBathrooms.image = #imageLiteral(resourceName: "check")
        } else {
            imgBathrooms.image = #imageLiteral(resourceName: "cross")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

