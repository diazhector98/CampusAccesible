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
    
    var locations = [Coordinate]()
    var paths = [Path]()

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
        let locationsNSArray = NSArray(contentsOfFile: locationsPath!)
        for (index, location) in locationsNSArray!.enumerated() {
            let castLocation = location as! NSDictionary
            locations.append(Coordinate(lat: castLocation.value(forKey: "longitud") as! Double, lon: castLocation.value(forKey: "latitud") as! Double, index: index))
        }
        let pathsPath = Bundle.main.path(forResource: "ListaCaminos", ofType: "plist")
        let pathsNSArray = NSArray(contentsOfFile: pathsPath!)
        for path in pathsNSArray! {
            let castPath = path as! NSDictionary
            paths.append(Path(coord1: locations[castPath.value(forKey: "punto1") as! Int], coord2: locations[castPath.value(forKey: "punto2") as! Int]))
        }
        
        for (index, location) in locations.enumerated() {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
            marker.title = String(location.lat) + " " + String(location.lon)
            marker.snippet = String(index)
            marker.map = mapView
        }

        for path in paths {
            let pointPath = GMSMutablePath()
            pointPath.add(CLLocationCoordinate2D(latitude: path.coord1.lat, longitude: path.coord1.lon))
            pointPath.add(CLLocationCoordinate2D(latitude: path.coord2.lat, longitude: path.coord2.lon))
            let line = GMSPolyline(path: pointPath)
            line.map = mapView
            line.strokeWidth = 5
        }
        
        let generator = PathCalculator(markers: locations, paths: paths, map: mapView)
        generator.showShortestPathOnMap(fromIndex: 16, toIndex: 8)
        
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

