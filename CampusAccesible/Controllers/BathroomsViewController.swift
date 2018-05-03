//
//  BathroomsViewController.swift
//  CampusAccesible
//
//  Created by Arturo González on 4/9/18.
//  Copyright © 2018 iOS Moviles. All rights reserved.
//

import UIKit

class BathroomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBOutlet weak var imgBuilding: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var bathrooms : NSArray!
    var buildingImage : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        imgBuilding.image = UIImage(named: buildingImage)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "Baños"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bathrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ExploreTableViewCell
        let dic = bathrooms[indexPath.row] as! NSDictionary
        
        cell.isUserInteractionEnabled = false
        
        cell.lbTitle?.text = dic.object(forKey: "nombre") as? String
        
        if (dic.object(forKey: "ambulatorio") as? Bool)! {
            cell.imgView?.image = #imageLiteral(resourceName: "Accessibility")
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
