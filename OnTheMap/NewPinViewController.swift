//
//  NewPinViewController.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/21/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit

class NewPinViewController: UIViewController {

    
    
    @IBOutlet weak var locationTextInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func findOnMapButton(_ sender: Any) {
    }

    @IBAction func backButton(_ sender: Any) {
    }
    
    
    
    
    func geocodeAddressDictionary(_ addressDictionary: [AnyHashable : Any],
                                  completionHandler: @escaping CLGeocodeCompletionHandler) {
    
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
