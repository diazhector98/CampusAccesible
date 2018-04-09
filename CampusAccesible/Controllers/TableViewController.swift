//
//  TableViewController.swift
//  CampusAccesible
//
//  Created by Arturo González on 3/15/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var buildingArray : NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explora"
        
        let path = Bundle.main.path(forResource: "ListaEdificios", ofType: "plist")!
        buildingArray = NSArray(contentsOfFile: path)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
 
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let exploreView = segue.destination as! ExploreViewController
        let indexP = tableView.indexPathForSelectedRow!
        let dic = buildingArray[indexP.row] as! NSDictionary
        
        exploreView.buildingImage = dic.object(forKey: "imagen") as! String
        exploreView.schedule = dic.object(forKey: "horario") as! String
        exploreView.elevator = dic.object(forKey: "elevador") as! Bool
        exploreView.bathrooms = dic.object(forKey: "banos") as! NSArray
    }

}
