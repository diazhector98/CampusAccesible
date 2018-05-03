//
//  TableViewController.swift
//  CampusAccesible
//
//  Created by Arturo González on 3/15/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBOutlet weak var infoBt: UIBarButtonItem!
    var buildingArray : NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explora"
        let path = Bundle.main.path(forResource: "ListaEdificios", ofType: "plist")!
        buildingArray = NSArray(contentsOfFile: path)
        buildingArray = buildingArray.filter({ ($0 as! NSDictionary)["show"] as! Bool}) as NSArray
        buildingArray = buildingArray.sorted(by: {($1 as! NSDictionary)["nombre"] as! String > ($0 as! NSDictionary)["nombre"] as! String}) as NSArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildingArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let dic = buildingArray[indexPath.row] as! NSDictionary
        
        cell.lbCell.text = dic.object(forKey: "nombre") as? String
        let image = UIImage(named: (dic.object(forKey: "imagen") as! String))
        cell.imgCell.image = image
        
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
 
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if !(sender is UIBarButtonItem) {
            let exploreView = segue.destination as! ExploreViewController
            let indexP = tableView.indexPathForSelectedRow!
            let dic = buildingArray[indexP.row] as! NSDictionary
            
            exploreView.buildingImage = dic.object(forKey: "imagen") as! String
            exploreView.schedule = dic.object(forKey: "horario") as! String
            if (dic.allKeys as! [String]).contains("elevador") {
                exploreView.showElevator = true
                exploreView.elevator = dic.object(forKey: "elevador") as! Bool
            }
            else {
                exploreView.showElevator = false
            }
            exploreView.bathrooms = dic.object(forKey: "banos") as! NSArray
            exploreView.buildingName = dic.object(forKey: "nombre") as! String
        }
    }

}
