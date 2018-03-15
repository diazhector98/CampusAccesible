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
    var nodes = [Node]()
    var map : GMSMapView
    var activeLine : GMSPolyline!

    init(markers : [Coordinate], paths : [Path], map: GMSMapView) {
        self.map = map
        graph = GKGraph()
        for marker in markers {
            nodes.append(Node(lat: marker.lat, lon: marker.lon))
        }
        graph.add(nodes)
        for path in paths {
            nodes[path.coord1.index].addConnection(to: nodes[path.coord2.index], weight: Float(path.distance))
        }
    }
    
    func showShortestPathOnMap(fromIndex: Int, toIndex: Int) {
        let path = graph.findPath(from: nodes[fromIndex], to: nodes[toIndex])
        let pointPath = GMSMutablePath()
        for element in path {
            let node = element as! Node
            pointPath.add(CLLocationCoordinate2D(latitude: node.lat, longitude: node.lon))
        }
        let line = GMSPolyline(path: pointPath)
        line.map = map
        line.strokeWidth = 5
        line.strokeColor = UIColor.red
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
