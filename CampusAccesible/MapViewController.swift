//
//  SecondViewController.swift
//  CampusAccesible
//
//  Created by Joao Gabriel Moura De Almeida on 3/14/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit
import GoogleMaps
import SearchTextField

class MapViewController: UIViewController {
    @IBOutlet weak var tfFrom: SearchTextField!
    @IBOutlet weak var tfTo: SearchTextField!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 25.651130, longitude: -100.289599, zoom: 17.0)
        mapView.camera = camera
        
        tfFrom.borderStyle = UITextBorderStyle.roundedRect
        tfTo.borderStyle = UITextBorderStyle.roundedRect
        self.view.bringSubview(toFront: tfFrom)
        self.view.bringSubview(toFront: tfTo)
        tfFrom.filterStrings(["Red", "Blue", "Yellow"])
        tfTo.filterStrings(["Red", "Blue", "Yellow"])
        tfFrom.maxResultsListHeight = 200
        tfTo.maxResultsListHeight = 200
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

