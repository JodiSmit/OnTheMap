//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/20/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    @IBOutlet weak var locationTable: UITableView!
   
    var locations = StudentDataSource.sharedInstance.studentData

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
        let cell = locationTable.dequeueReusableCell(withIdentifier: "StudentViewCell") as UITableViewCell!
        
        cell?.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell?.imageView?.image = UIImage(named: "icon_pin")
        cell?.detailTextLabel?.text = studentLocation.linkUrl
        
        return cell!
    }
    
    //MARK: Function to load Student's URL on row selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let studentLocation = locations[indexPath.row]
        
        var completeURL = studentLocation.linkUrl
        
        if studentLocation.linkUrl.range(of: "http://") == nil && studentLocation.linkUrl.range(of: "https://") == nil  {
            completeURL = "http://" + studentLocation.linkUrl
        }
        print(completeURL)
        
        if let studentUrl = URL(string: completeURL) {
            UIApplication.shared.open(studentUrl as URL)
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
        
        StudentDataSource.sharedInstance.studentData.removeAll()
        ParseClient.sharedInstance.getStudentInformation( completionHandler: {(success, ErrorMessage) -> Void in
            if success {
                self.locations = StudentDataSource.sharedInstance.studentData
                performUIUpdatesOnMain {
                    self.locationTable.reloadData()
                }
            } else {
                self.showAlert((Any).self, message: UdacityClient.ErrorMessages.refreshError)
            }
        })
    }
    
    // MARK: -  Error alert setup
    func showAlert(_ sender: Any, message: String) {
        let errMessage = message
        
        let alert = UIAlertController(title: nil, message: errMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: Logout button function to logout of Udacity and return to login screen.
    @IBAction func logoutButtonPressed(_ sender: Any) {
        UdacityClient.sharedInstance.deleteCurrentUser( {(success, ErrorMessage) -> Void in
            if success {
                performUIUpdatesOnMain {
                    StudentDataSource.sharedInstance.studentData.removeAll()
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                performUIUpdatesOnMain  {
                    self.showAlert((Any).self, message: UdacityClient.ErrorMessages.logoutError)
                }
                
            }
        })
    }
}
