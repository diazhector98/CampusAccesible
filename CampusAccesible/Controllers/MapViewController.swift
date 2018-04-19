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
        isAccessibleSwitch.backgroundColor = UIColor.white
        isAccessibleSwitch.layer.cornerRadius = 16.0
        let blue = UIColor(red: 65.0/255.0, green: 80.0/255.0, blue: 182/255.0, alpha: 1.0)
        isAccessibleSwitch.onTintColor = blue
        
        // Creación del mapa
        let camera = GMSCameraPosition.camera(withLatitude: 25.651130, longitude: -100.289599, zoom: 17.0)
        mapView.camera = camera

        // Restricciones del movimiento del mapa
        mapView.setMinZoom(17.0, maxZoom: 21.0)
        let upperLeftBound = CLLocationCoordinate2D(latitude: 25.653485, longitude: -100.292080)
        let lowerRightBound = CLLocationCoordinate2D(latitude: 25.648031, longitude: -100.286508)
        let bounds = GMSCoordinateBounds(coordinate: upperLeftBound, coordinate: lowerRightBound)
        mapView.cameraTargetBounds = bounds
        
        // Esconde teclado cuando presiona afuera
        let tap = UITapGestureRecognizer(target: self, action: #selector(quitaTeclado))
        view.addGestureRecognizer(tap)
        
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
        
        if false {
            // TESTING Muestra todos los marcadores
            for (index, location) in locations.enumerated() {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
                marker.title = String(location.lat) + " " + String(location.lon)
                marker.snippet = String(index)
                marker.map = mapView
            }
            
            // TESTING Muestra todos los caminos
            for path in paths {
                let pointPath = GMSMutablePath()
                pointPath.add(CLLocationCoordinate2D(latitude: path.coord1.lat, longitude: path.coord1.lon))
                pointPath.add(CLLocationCoordinate2D(latitude: path.coord2.lat, longitude: path.coord2.lon))
                let line = GMSPolyline(path: pointPath)
                line.map = mapView
                if path.isAccessible {
                    line.strokeColor = UIColor.blue
                }
                else {
                    line.strokeColor = UIColor.black
                }
                line.strokeWidth = 5
            }
        }
        
        generator = PathCalculator(markers: locations, paths: paths, map: mapView)
        
        // Estilo y datos que se filtran
        tfFrom.borderStyle = UITextBorderStyle.roundedRect
        tfTo.borderStyle = UITextBorderStyle.roundedRect
        let buildingNames = buildings.map({ (key: String, building: Building) -> String in
            building.name
        })
        
        // Agrega los dropdowns
        tfFrom.filterStrings(buildingNames)
        tfTo.filterStrings(buildingNames)
        tfFrom.maxResultsListHeight = 200
        tfTo.maxResultsListHeight = 200
        
        // Actualiza ruta cuando se selecciona valor del dropdown
        tfFrom.itemSelectionHandler = didSelectOrigin(_:_:)
        tfTo.itemSelectionHandler = didSelectDestination(_:_:)
        
        // Actualiza ruta cuando se escribe un valor valido
        tfFrom.addTarget(self, action: #selector(tfDidChange(_:)), for: .editingChanged)
        tfTo.addTarget(self, action: #selector(tfDidChange(_:)), for: .editingChanged)
        
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
    
    @objc func tfDidChange(_ textField: UITextField) {
        updateRoute()
    }
    
    @IBAction func destinationChosen(_ sender: SearchTextField) {
        let fromBuildingName = tfFrom.text
        let toBuildingName = tfTo.text
        if (fromBuildingName?.isEmpty)! || (toBuildingName?.isEmpty)! || buildings[fromBuildingName!] == nil || buildings[toBuildingName!] == nil {
            let alerta = UIAlertController(title: "Error", message: "Porfavor revisa el nombre de los edificios seleccionados.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alerta, animated: true, completion: nil)
            return
        }
        updateRoute()
    }
    
    func didSelectDestination(_ filteredResults: [SearchTextFieldItem], _ index: Int) -> Void {
        tfTo.text = filteredResults[index].title
        updateRoute()
    }
    
    func didSelectOrigin(_ filteredResults: [SearchTextFieldItem], _ index: Int) -> Void {
        tfFrom.text = filteredResults[index].title
        updateRoute()
    }
    
    func updateRoute() {
        let fromBuildingName = tfFrom.text
        let toBuildingName = tfTo.text
        if !(fromBuildingName?.isEmpty)! && buildings[fromBuildingName!] != nil {
            generator.setFromMarker(index: (buildings[fromBuildingName!]?.coord_index)!)
        }
        if !(toBuildingName?.isEmpty)! && buildings[toBuildingName!] != nil {
            generator.setToMarker(index: (buildings[toBuildingName!]?.coord_index)!)
        }
        if (fromBuildingName?.isEmpty)! || (toBuildingName?.isEmpty)! || buildings[fromBuildingName!] == nil || buildings[toBuildingName!] == nil {
            return
        }
        
        let fromBuilding = buildings[fromBuildingName!]!
        let toBuilding = buildings[toBuildingName!]!
        currentFromIndex = fromBuilding.coord_index
        currentToIndex = toBuilding.coord_index
        generator.showShortestPathOnMap(fromIndex: currentFromIndex, toIndex: currentToIndex, isAccessible: isAccessibleSwitch.isOn)
    }
    
    @IBAction func quitaTeclado() {
        view.endEditing(true)
    }
    
    
}
