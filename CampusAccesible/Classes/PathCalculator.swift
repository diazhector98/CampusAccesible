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
class PathCalculator: NSObject {
    
    var graph : GKGraph
    var accessibleGraph : GKGraph
    var nodes = [Node]()
    var accessibleNodes = [Node]()
    var map : GMSMapView
    var activeLine = GMSPolyline()
    var activeMarkerFrom : GMSMarker!
    var activeMarkerTo : GMSMarker!

    init(markers : [Coordinate], paths : [Path], map: GMSMapView) {
        self.map = map
        graph = GKGraph()
        accessibleGraph = GKGraph()
        for marker in markers {
            nodes.append(Node(lat: marker.lat, lon: marker.lon))
            accessibleNodes.append(Node(lat: marker.lat, lon: marker.lon))
        }
        graph.add(nodes)
        accessibleGraph.add(accessibleNodes)
        for path in paths {
            nodes[path.coord1.index].addConnection(to: nodes[path.coord2.index], weight: Float(path.distance))
            if path.isAccessible {
                accessibleNodes[path.coord1.index].addConnection(to: accessibleNodes[path.coord2.index], weight: Float(path.distance))
            }
        }
        activeLine.strokeWidth = 5
        
    }
    
    func showShortestPathOnMap(fromIndex: Int, toIndex: Int, isAccessible: Bool) {
        activeLine.map = nil
        var path : [GKGraphNode]
        if isAccessible {
            path = accessibleGraph.findPath(from: accessibleNodes[fromIndex], to: accessibleNodes[toIndex])
        }
        else {
            path = graph.findPath(from: nodes[fromIndex], to: nodes[toIndex])
        }
        let pointPath = GMSMutablePath()
        for element in path {
            let node = element as! Node
            pointPath.add(CLLocationCoordinate2D(latitude: node.lat, longitude: node.lon))
        }
        activeLine.path = pointPath
        if isAccessible {
            activeLine.strokeColor = UIColor.blue
        }
        else {
            activeLine.strokeColor = UIColor.red
        }
        activeLine.map = map

        
        let midPointLat = (nodes[toIndex].lat + nodes[fromIndex].lat)/2 + 0.0005
        let midPointLon = (nodes[toIndex].lon + nodes[fromIndex].lon)/2
        map.animate(toLocation: CLLocationCoordinate2D(latitude: midPointLat, longitude: midPointLon))

        
    }
    
    func setFromMarker(index: Int) {
        if activeMarkerFrom != nil {
            if activeMarkerFrom.position.latitude == nodes[index].lat && activeMarkerFrom.position.longitude == nodes[index].lon {
                return
            }
            activeMarkerFrom.map = nil
        }

        activeMarkerFrom = GMSMarker()
        activeMarkerFrom.appearAnimation = GMSMarkerAnimation.pop
        activeMarkerFrom.position = CLLocationCoordinate2D(latitude: nodes[index].lat, longitude: nodes[index].lon)
        activeMarkerFrom.map = map
    }
    
    func setToMarker(index: Int) {
        if activeMarkerTo != nil {
            if activeMarkerTo.position.latitude == nodes[index].lat && activeMarkerTo.position.longitude == nodes[index].lon {
                return
            }
            activeMarkerTo.map = nil
        }
        activeMarkerTo = GMSMarker()
        activeMarkerTo.appearAnimation = GMSMarkerAnimation.pop
        activeMarkerTo.position = CLLocationCoordinate2D(latitude: nodes[index].lat, longitude: nodes[index].lon)
        activeMarkerTo.map = map
    }
    
    func showBuildingCoords(indexes: [Int]) {
        hideRoute()
        var markers = [GMSMarker]()
        for index in indexes {
            let marker = GMSMarker()
            marker.appearAnimation = GMSMarkerAnimation.pop
            marker.position = CLLocationCoordinate2D(latitude: nodes[index].lat, longitude: nodes[index].lon)
            marker.icon = GMSMarker.markerImage(with: UIColor.green)
            marker.map = map
            markers.append(marker)
        }
    }
    
    func hideRoute() {
        if activeMarkerTo != nil {
            activeMarkerTo.map = nil
        }
        if activeMarkerFrom != nil {
            activeMarkerFrom.map = nil
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
