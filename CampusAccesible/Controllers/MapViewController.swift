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
import NotificationBannerSwift

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var tfFrom: SearchTextField!
    @IBOutlet weak var tfTo: SearchTextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var isAccessibleSwitch: UISwitch!
    
    
    var generator : PathCalculator!
    var locations = [Coordinate]()
    var paths = [Path]()
    var buildings = [String : Building]()
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAccessibleSwitch.isOn = false
        isAccessibleSwitch.backgroundColor = UIColor.white
        isAccessibleSwitch.layer.cornerRadius = 16.0
        let blue = UIColor(red: 65.0/255.0, green: 80.0/255.0, blue: 182/255.0, alpha: 1.0)
        isAccessibleSwitch.onTintColor = blue
        
        // Creación del mapa
        let camera = GMSCameraPosition.camera(withLatitude: 25.6515, longitude: -100.289599, zoom: 16.6)
        mapView.camera = camera
        self.mapView?.isMyLocationEnabled = true
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        // Restricciones del movimiento del mapa
        mapView.setMinZoom(16.0, maxZoom: 21.0)
        let upperLeftBound = CLLocationCoordinate2D(latitude: 25.653485, longitude: -100.292080)
        let lowerRightBound = CLLocationCoordinate2D(latitude: 25.648031, longitude: -100.286508)
        let bounds = GMSCoordinateBounds(coordinate: upperLeftBound, coordinate: lowerRightBound)
        mapView.cameraTargetBounds = bounds
        
        // Esconde teclado cuando presiona afuera
        let tap = UITapGestureRecognizer(target: self, action: #selector(quitaTeclado))
        view.addGestureRecognizer(tap)
        
        // Inicializa PropertyLists
        locations = Coordinate.loadCoordinateArray()
        paths = Path.loadPathArray(locations: locations)
        buildings = Building.loadBuildingMap()
        
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
        generator.isAccessible = isAccessibleSwitch.isOn
        generator.showShortestPathOnMap()
    }
    
    @objc func tfDidChange(_ textField: SearchTextField) {
        if generator.isSelectingMarker {
            if generator.originIsActive {
                if textField == tfTo {
                    tfFrom.text = ""
                }
            }
            else if textField == tfFrom {
                tfTo.text = ""
            }
        }
        updateRoute(textField: textField)
    }
    
    @IBAction func destinationChosen(_ sender: SearchTextField) {
        let fromBuildingName = tfFrom.text
        let toBuildingName = tfTo.text
        if (fromBuildingName?.isEmpty)! || (toBuildingName?.isEmpty)! || buildings[fromBuildingName!] == nil || buildings[toBuildingName!] == nil {
            let banner = NotificationBanner(title: "Error", subtitle: "Nombre de edificio inválido.", style: .warning)
            banner.show()
            return
        }
    }
    
    func didSelectDestination(_ filteredResults: [SearchTextFieldItem], _ index: Int) -> Void {
        tfTo.text = filteredResults[index].title
        updateRoute(textField: tfTo)
    }
    
    func didSelectOrigin(_ filteredResults: [SearchTextFieldItem], _ index: Int) -> Void {
        tfFrom.text = filteredResults[index].title
        updateRoute(textField: tfFrom)
    }
    
    func updateRoute(textField: SearchTextField) {
        generator.isAccessible = isAccessibleSwitch.isOn
        
        // Esconde el dropdown si el valor actual es un valor valido
        if !(textField.text?.isEmpty)! && buildings[textField.text!] != nil {
            textField.hideResultsList()
        }
        
        // Checa si el edificio tiene varias coordenadas
        if (textField.text != nil && buildings[textField.text!] != nil) {
            guard let coords = buildings[textField.text!]?.coord_index else {
                return
            }
            if coords.count > 1 {
                // Muestra las coordenadas como marcadores para que el usuario seleccione uno
                generator.showBuildingCoords(indexes: coords, isOrigin: textField == tfFrom)
                return
            }
            
        }
        
        // Si el valor es valido, muestra el marcador
        if !((textField.text?.isEmpty)!) && buildings[textField.text!] != nil {
            if textField == tfFrom {
                generator.setFromMarker(index: (buildings[textField.text!]?.coord_index[0])!)
            }
            else {
                generator.setToMarker(index: (buildings[textField.text!]?.coord_index[0])!)
            }
            
            // Calcula ruta (de ser posible)
            generator.showShortestPathOnMap()
        }
        
        // El valor no es valido, quita marcador
        else {
            if textField == tfFrom {
                generator.removeFromMarker()
            }
            else {
                generator.removeToMarker()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
    }
    
    @IBAction func quitaTeclado() {
        view.endEditing(true)
    }
}
