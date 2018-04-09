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
    @IBOutlet weak var isAccessibleSwitch: UISwitch!
    
    
    var generator : PathCalculator!
    var locations = [Coordinate]()
    var paths = [Path]()
    var buildings = [String : Building]()
    var currentFromIndex = 0
    var currentToIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAccessibleSwitch.isOn = false
        
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
        let locationsPath = Bundle.main.path(forResource: "Coords", ofType: "plist")
        let locationsNSArray = NSArray(contentsOfFile: locationsPath!)
        for (index, location) in locationsNSArray!.enumerated() {
            let castLocation = location as! NSDictionary
            locations.append(Coordinate(lat: castLocation.value(forKey: "longitud") as! Double, lon: castLocation.value(forKey: "latitud") as! Double, index: index))
        }
        
        let pathsPath = Bundle.main.path(forResource: "ListaCaminos", ofType: "plist")
        let pathsNSArray = NSArray(contentsOfFile: pathsPath!)
        for path in pathsNSArray! {
            let castPath = path as! NSDictionary
            paths.append(Path(coord1: locations[castPath.value(forKey: "punto1") as! Int], coord2: locations[castPath.value(forKey: "punto2") as! Int], coord1_index: castPath.value(forKey: "punto1") as! Int, coord2_index: castPath.value(forKey: "punto2") as! Int, isAccessible: castPath.value(forKey: "accesible") as! Bool))
        }
        
        let buildingsPath = Bundle.main.path(forResource: "ListaEdificios", ofType: "plist")
        let buildingsNSArray = NSArray(contentsOfFile: buildingsPath!)
        for building in buildingsNSArray! {
            let castBuilding = building as! NSDictionary
            buildings[castBuilding.value(forKey: "nombre") as! String] = (Building(name: castBuilding.value(forKey: "nombre") as! String, image: UIImage(named: castBuilding.value(forKey: "imagen") as! String)!, elevator: castBuilding.value(forKey: "elevador") as! Bool, schedule: castBuilding.value(forKey: "horario") as! String, bathrooms: castBuilding.value(forKey: "banos") as! [String], coord_index: castBuilding.value(forKey: "coord") as! Int))
        }
        
        generator = PathCalculator(markers: locations, paths: paths, map: mapView)
        
        // Estilo y datos que se filtran
        tfFrom.borderStyle = UITextBorderStyle.roundedRect
        tfTo.borderStyle = UITextBorderStyle.roundedRect
        let buildingNames = buildings.map({ (key: String, building: Building) -> String in
            building.name
        })
        tfFrom.filterStrings(buildingNames)
        tfTo.filterStrings(buildingNames)
        tfFrom.maxResultsListHeight = 200
        tfTo.maxResultsListHeight = 200
        
        // Pone Text Fields arriba del mapa
        self.view.bringSubview(toFront: tfFrom)
        self.view.bringSubview(toFront: tfTo)
        self.view.bringSubview(toFront: isAccessibleSwitch)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleAccessibleSwitch(_ sender: UISwitch) {
        generator.showShortestPathOnMap(fromIndex: currentFromIndex, toIndex: currentToIndex, isAccessible: isAccessibleSwitch.isOn)
    }
    
    @IBAction func destinationChosen(_ sender: SearchTextField) {
        let fromBuildingName = tfFrom.text
        let toBuildingName = tfTo.text
        if (fromBuildingName?.isEmpty)! || (toBuildingName?.isEmpty)! || buildings[fromBuildingName!] == nil || buildings[toBuildingName!] == nil {
            print("no existe")
            //notifica
            return
        }
        
        let fromBuilding = buildings[fromBuildingName!]!
        let toBuilding = buildings[toBuildingName!]!
        
        generator.showShortestPathOnMap(fromIndex: fromBuilding.coord_index, toIndex: toBuilding.coord_index, isAccessible: false)
        
        let markerFrom = GMSMarker()
        markerFrom.position = CLLocationCoordinate2D(latitude: locations[fromBuilding.coord_index].lat, longitude: locations[fromBuilding.coord_index].lon)
        markerFrom.title = fromBuildingName
        markerFrom.map = mapView
        
        let markerTo = GMSMarker()
        markerTo.position = CLLocationCoordinate2D(latitude: locations[toBuilding.coord_index].lat, longitude: locations[toBuilding.coord_index].lon)
        markerTo.title = fromBuildingName
        markerTo.map = mapView
        
        currentFromIndex = fromBuilding.coord_index
        currentToIndex = toBuilding.coord_index
        let midPointLat = (locations[toBuilding.coord_index].lat + locations[fromBuilding.coord_index].lat)/2
        let midPointLon = (locations[toBuilding.coord_index].lon + locations[fromBuilding.coord_index].lon)/2
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: midPointLat, longitude: midPointLon))
    }
}

