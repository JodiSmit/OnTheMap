//
//  TableTableViewController.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/20/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit

class TableTableViewController: UITableViewController {

    let locations = ParseClient.students

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: Returns location count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    //MARK: Cell population
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let studentLocation = locations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentViewCell") as UITableViewCell!
        
        cell?.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell?.imageView?.image = UIImage(named: "icon_pin")
        cell?.detailTextLabel?.text = studentLocation.linkUrl
        
        return cell!
    }
    
    //MARK: Function to load Student's URL on row selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let studentLocation = locations[indexPath.row]
        
        if let studentUrl = URL(string: studentLocation.linkUrl), UIApplication.shared.canOpenURL(studentUrl) {
            UIApplication.shared.open(studentUrl, options: [:])
        } else {
            let alertController = UIAlertController()
            
            alertController.title = "Not a Valid URL"
            alertController.message = "The URL is not available, please select a different student."
            
            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
            alertController.addAction(dismissAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: Remove and re-add all pins (refresh)
    @IBAction func refreshStudentPins(_ sender: Any) {
        performUIUpdatesOnMain {
            self.tableView.reloadData()
        }
    }
    
}
