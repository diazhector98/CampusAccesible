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
        
        mapView.setMinZoom(17.0, maxZoom: 21.0)
        
        let upperLeftBound = CLLocationCoordinate2D(latitude: 25.653485, longitude: -100.292080)
        let lowerRightBound = CLLocationCoordinate2D(latitude: 25.648031, longitude: -100.286508)
        let bounds = GMSCoordinateBounds(coordinate: upperLeftBound, coordinate: lowerRightBound)
        
        mapView.cameraTargetBounds = bounds
        
        tfFrom.borderStyle = UITextBorderStyle.roundedRect
        tfTo.borderStyle = UITextBorderStyle.roundedRect
        self.view.bringSubview(toFront: tfFrom)
        self.view.bringSubview(toFront: tfTo)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

