//
//  FirstViewController.swift
//  CampusAccesible
//
//  Created by Joao Gabriel Moura De Almeida on 3/14/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBOutlet weak var imgBuilding: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    
    var buildingImage : String!
    var schedule : String!
    var elevator : Bool!
    var bathrooms : NSArray!
    var buildingName : String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgBuilding.image = UIImage(named: buildingImage)
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = buildingName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PExploreTableViewCell
        
        if indexPath.row == 0 {
            cell.imgView?.image = #imageLiteral(resourceName: "clock")
            cell.lbTitle?.text = schedule
            cell.isUserInteractionEnabled = false
        } else if indexPath.row == 1 {
            cell.isUserInteractionEnabled = false
            if elevator {
                cell.imgView?.image = #imageLiteral(resourceName: "checkmark")
            } else {
                cell.imgView?.image = #imageLiteral(resourceName: "cross")
            }
            cell.lbTitle?.text = "Elevador"
        } else if indexPath.row == 2 {
            cell.accessoryType = .disclosureIndicator
            if bathrooms.count > 0 {
                cell.imgView?.image = #imageLiteral(resourceName: "checkmark")
            } else {
                cell.imgView?.image = #imageLiteral(resourceName: "cross")
            }
            cell.lbTitle?.text = "Baños"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            performSegue(withIdentifier: "ShowBathrooms") {
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let bathroomsView = segue.destination as! BathroomsViewController
        
        bathroomsView.bathrooms = bathrooms as NSArray?
        bathroomsView.buildingImage = buildingImage as String?
     }
}

