//
//  PathCalculator.swift
//  CampusAccesible
//
//  Created by Luis Villarreal on 3/14/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit
import GameplayKit
import GoogleMaps
import NotificationBannerSwift

class PathCalculator: NSObject, GMSMapViewDelegate {
    
    var graph : GKGraph
    var accessibleGraph : GKGraph
    var nodes = [Node]()
    var accessibleNodes = [Node]()
    var map : GMSMapView
    
    var activeLine = GMSPolyline()
    var activeFromIndex : Int!
    var activeToIndex : Int!
    var isAccessible : Bool!
    var activeMarkerFrom : GMSMarker!
    var activeMarkerTo : GMSMarker!
    var selectableMarkers = [GMSMarker]()
    var originIsActive : Bool!
    var isSelectingMarker = false
    
    let banner = NotificationBanner(title: "Selecciona la ubicación deseada", subtitle: "El edificio seleccionado tiene varias secciones.", style: .info)

    init(markers : [Coordinate], paths : [Path], map: GMSMapView) {
        self.map = map
        
        // Crea los grafos
        graph = GKGraph()
        accessibleGraph = GKGraph()
        
        // Agrega los nodos
        for marker in markers {
            nodes.append(Node(lat: marker.lat, lon: marker.lon))
            accessibleNodes.append(Node(lat: marker.lat, lon: marker.lon))
        }
        graph.add(nodes)
        accessibleGraph.add(accessibleNodes)
        
        // Agrega las conexiones
        for path in paths {
            nodes[path.coord1.index].addConnection(to: nodes[path.coord2.index], weight: Float(path.distance))
            if path.isAccessible {
                accessibleNodes[path.coord1.index].addConnection(to: accessibleNodes[path.coord2.index], weight: Float(path.distance))
            }
        }
        activeLine.strokeWidth = 5
        
    }
    
    func showShortestPathOnMap() {
        // Esconde la ruta actual
        activeLine.map = nil
        
        // Si no hay un indice valido de origen y destino termina
        if activeFromIndex == nil || activeToIndex == nil {
            return
        }
        
        // Asegura que se esten mostrando ambos marcadores
        activeMarkerTo.map = map
        activeMarkerFrom.map = map
        
        // Calcula la ruta mas corta
        var path : [GKGraphNode]
        if isAccessible {
            path = accessibleGraph.findPath(from: accessibleNodes[activeFromIndex], to: accessibleNodes[activeToIndex])
        }
        else {
            path = graph.findPath(from: nodes[activeFromIndex], to: nodes[activeToIndex])
        }
        
        // Muestra la ruta
        let pointPath = GMSMutablePath()
        var minLat = 999999999.0
        var minLon = 999999999.0
        var maxLat = -999999999.0
        var maxLon = -999999999.0
        for element in path {
            let node = element as! Node
            pointPath.add(CLLocationCoordinate2D(latitude: node.lat, longitude: node.lon))
            if node.lat > maxLat {
                maxLat = node.lat
            }
            if node.lat < minLat {
                minLat = node.lat
            }
            if node.lon > maxLon {
                maxLon = node.lon
            }
            if node.lon < minLon {
                minLon = node.lon
            }
        }
        
        let distance = maxLat - minLat
        maxLat += distance/0.004004 * 0.0025
        
        let coordinateBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon), coordinate: CLLocationCoordinate2D(latitude: minLat, longitude: minLon))
        activeLine.path = pointPath
        if isAccessible {
            activeLine.strokeColor = UIColor.blue
        }
        else {
            activeLine.strokeColor = UIColor.red
        }
        activeLine.map = map

        // Mueve el mapa
        let midPointLat = (nodes[activeToIndex].lat + nodes[activeFromIndex].lat)/2 + 0.0005
        let midPointLon = (nodes[activeToIndex].lon + nodes[activeFromIndex].lon)/2
        map.animate(toLocation: CLLocationCoordinate2D(latitude: midPointLat, longitude: midPointLon))
        let update = GMSCameraUpdate.fit(coordinateBounds)
        map.animate(with: update)

        
    }
    
    func setFromMarker(index: Int) {
        if activeFromIndex != nil {
            if activeFromIndex == index {
                return
            }
            removeFromMarker()
        }
        removeFromMarker()
        activeFromIndex = index
        activeMarkerFrom = GMSMarker()
        activeMarkerFrom.appearAnimation = GMSMarkerAnimation.pop
        activeMarkerFrom.position = CLLocationCoordinate2D(latitude: nodes[index].lat, longitude: nodes[index].lon)
        activeMarkerFrom.map = map
    }
    
    func removeFromMarker() {
        if isSelectingMarker {
            removeSelectableMarkers()
        }
        activeFromIndex = nil
        if activeMarkerFrom != nil {
            activeMarkerFrom.map = nil
            activeMarkerFrom = nil
        }
        
        activeLine.map = nil
        
        // Verifica que el otro marcador se este mostrando, si es posible
        if activeMarkerTo != nil {
            activeMarkerTo.map = map
        }
    }
    
    func setToMarker(index: Int) {
        if activeToIndex != nil {
            if activeToIndex == index {
                return
            }
            removeToMarker()
        }
        
        activeToIndex = index
        activeMarkerTo = GMSMarker()
        activeMarkerTo.appearAnimation = GMSMarkerAnimation.pop
        activeMarkerTo.position = CLLocationCoordinate2D(latitude: nodes[index].lat, longitude: nodes[index].lon)
        activeMarkerTo.map = map
    }
    
    func removeToMarker() {
        if isSelectingMarker {
            removeSelectableMarkers()
        }
        activeToIndex = nil
        if activeMarkerTo != nil {
            activeMarkerTo.map = nil
            activeMarkerTo = nil
        }
        
        // Verifica que el otro marcador se este mostrando, si es posible
        if activeMarkerFrom != nil {
            activeMarkerFrom.map = map
        }
        activeLine.map = nil
    }
    
    
    // Se utiliza para mostrar varios markers cuando un edificio tiene varias coordenadas posibles
    func showBuildingCoords(indexes: [Int], isOrigin: Bool) {
        hideRoute()
        
        var midPointLat = 0.0
        var midPointLon = 0.0

        var minLat = 999999999.0
        var minLon = 999999999.0
        var maxLat = -999999999.0
        var maxLon = -999999999.0
        
        for index in indexes {
            let marker = GMSMarker()
            marker.appearAnimation = GMSMarkerAnimation.pop
            marker.position = CLLocationCoordinate2D(latitude: nodes[index].lat, longitude: nodes[index].lon)
            marker.icon = GMSMarker.markerImage(with: UIColor.blue)
            marker.map = map
            marker.title = String(index)
            selectableMarkers.append(marker)
            
            midPointLat += nodes[index].lat
            midPointLon += nodes[index].lon
            
            if nodes[index].lat > maxLat {
                maxLat = nodes[index].lat
            }
            if nodes[index].lat < minLat {
                minLat = nodes[index].lat
            }
            if nodes[index].lon > maxLon {
                maxLon = nodes[index].lon
            }
            if nodes[index].lon < minLon {
                minLon = nodes[index].lon
            }
        }
        
        let distance = maxLat - minLat
        maxLat += distance/0.004004 * 0.0025
        minLat -= 0.001
        maxLat += 0.001
        
        let coordinateBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon), coordinate: CLLocationCoordinate2D(latitude: minLat, longitude: minLon))
        
        map.delegate = self
        originIsActive = isOrigin
        isSelectingMarker = true
        
        banner.autoDismiss = false
        banner.show()
        
        midPointLon /= Double(indexes.count)
        midPointLat /= Double(indexes.count)
        midPointLat += 0.0005
        map.animate(toLocation: CLLocationCoordinate2D(latitude: midPointLat, longitude: midPointLon))
        let update = GMSCameraUpdate.fit(coordinateBounds)
        map.animate(with: update)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Verifica si el usuario hizo click en uno de los markers mostrados por showBuildingCoords
        if isSelectingMarker {
            if originIsActive {
                setFromMarker(index: Int(marker.title!)!)
            }
            else {
                setToMarker(index: Int(marker.title!)!)
            }
            removeSelectableMarkers()
            showShortestPathOnMap()
            return true
        }
        return false
    }
    
    // Elimina los marcadores creados por showBuildingCoords
    func removeSelectableMarkers() {
        for marker in selectableMarkers {
            marker.map = nil
        }
        selectableMarkers.removeAll()
        isSelectingMarker = false
        banner.dismiss()
    }
    
    // Esconde los marcadores y la ruta
    func hideRoute() {
        if activeMarkerTo != nil {
            activeMarkerTo.map = nil
        }
        if activeMarkerFrom != nil {
            activeMarkerFrom.map = nil
        }
        if isSelectingMarker {
            removeSelectableMarkers()
        }
        activeLine.map = nil
    }
    
    
}

class Node: GKGraphNode {
    var travelCost: [GKGraphNode: Float] = [:]
    var lat : Double
    var lon : Double
    
    init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.lat = 0
        self.lon = 0
        super.init()
    }
    
    override func cost(to node: GKGraphNode) -> Float {
        return travelCost[node] ?? 0
    }
    
    func addConnection(to node: GKGraphNode, bidirectional: Bool = true, weight: Float) {
        self.addConnections(to: [node], bidirectional: bidirectional)
        travelCost[node] = weight
        guard bidirectional else { return }
        (node as? Node)?.travelCost[self] = weight
    }
}
