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
    
    var locations : NSArray!
    var buildings : NSArray!
    var keyPoints : NSArray!
    var paths : NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creación del mapa
        let camera = GMSCameraPosition.camera(withLatitude: 25.651130, longitude: -100.289599, zoom: 17.0)
        mapView.camera = camera

        // Restricciones del movimiento del mapa
        mapView.setMinZoom(17.0, maxZoom: 21.0)
        let upperLeftBound = CLLocationCoordinate2D(latitude: 25.653485, longitude: -100.292080)
        let lowerRightBound = CLLocationCoordinate2D(latitude: 25.648031, longitude: -100.286508)
        let bounds = GMSCoordinateBounds(coordinate: upperLeftBound, coordinate: lowerRightBound)
        mapView.cameraTargetBounds = bounds
        
        // Inicializa PropertyLists
        let locationsPath = Bundle.main.path(forResource: "Property List", ofType: "plist")
        locations = NSArray(contentsOfFile: locationsPath!)
        let buildingsPath = Bundle.main.path(forResource: "ListaEdificios", ofType: "plist")
        buildings = NSArray(contentsOfFile: buildingsPath!)
        let keyPointsPath = Bundle.main.path(forResource: "PuntosClave", ofType: "plist")
        keyPoints = NSArray(contentsOfFile: keyPointsPath!)
        let pathsPath = Bundle.main.path(forResource: "ListaCaminos", ofType: "plist")
        paths = NSArray(contentsOfFile: pathsPath!)
        
        for (index, element) in locations.enumerated() {
            let marker = GMSMarker()
            let location = element as! NSDictionary
            marker.position = CLLocationCoordinate2D(latitude: location.value(forKey: "longitud") as! Double, longitude: location.value(forKey: "latitud") as! Double)
            marker.title = String(marker.position.latitude) + " " + String(marker.position.longitude)
            marker.snippet = String(index)
            marker.map = mapView
        }
        
        for element in paths {
            let path = element as! NSDictionary
            let pointPath = GMSMutablePath()
            let point1 = path.value(forKey: "punto1") as! Int
            let point2 = path.value(forKey: "punto2") as! Int
            let dic1 = locations[point1] as! NSDictionary
            let dic2 = locations[point2] as! NSDictionary
            pointPath.add(CLLocationCoordinate2D(latitude: dic1.value(forKey: "longitud") as! Double, longitude: dic1.value(forKey: "latitud") as! Double))
            pointPath.add(CLLocationCoordinate2D(latitude: dic2.value(forKey: "longitud") as! Double, longitude: dic2.value(forKey: "latitud") as! Double))
            let line = GMSPolyline(path: pointPath)
            line.map = mapView
            line.strokeWidth = 5
        }
        
        
        // Estilo y datos que se filtran
        tfFrom.borderStyle = UITextBorderStyle.roundedRect
        tfTo.borderStyle = UITextBorderStyle.roundedRect
        tfFrom.filterStrings(["Red", "Blue", "Yellow"])
        tfTo.filterStrings(["Red", "Blue", "Yellow"])
        tfFrom.maxResultsListHeight = 200
        tfTo.maxResultsListHeight = 200
        
        // Pone Text Fields arriba del mapa
        self.view.bringSubview(toFront: tfFrom)
        self.view.bringSubview(toFront: tfTo)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

