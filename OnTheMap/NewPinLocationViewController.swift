//
//  NewPinLocationViewController.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/27/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class NewPinLocationViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findButton: RoundedButton!
    @IBOutlet weak var locationInput: UITextField!
    
    
    var userLocation: String?
    var coordinates: CLLocationCoordinate2D?
    lazy var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationInput.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewResizerOnKeyboardShown()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: After user input of location, new VC will load to ask for URL detail.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddPin" {
            if let addPinController = segue.destination as? AddPinViewController {
                addPinController.inputCoordinates = coordinates
                addPinController.geocodedLocation = userLocation
            }
        } else {
            return
        }
    }
    
    //MARK: Find button tapped
    @IBAction func findButtonPressed(_ sender: Any) {
        startGeocoding()
        guard locationInput.text!.isEmpty == false else {
            self.showAlert(findButton!, message: UdacityClient.ErrorMessages.urlInputError)
            return
        }
        userLocation = locationInput.text!
        performUIUpdatesOnMain {
            self.geocodeAddress(self.userLocation!)

        }
    }
    
    //MARK: Cancel button tapped
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Function to geocode address String
    private func geocodeAddress(_ inputLocation: String) {
        self.geocoder.geocodeAddressString(inputLocation) { (placemarks, error) -> Void in
            
            if error != nil {
                self.stopGeocoding()
                self.showAlert(self.findButton, message: UdacityClient.ErrorMessages.geoError)
                self.locationInput.text = ""
                
            } else {
                var location: CLLocation?
                
                if let placemarks = placemarks, placemarks.count > 0 {
                    location = placemarks.first?.location
                }
                
                if let location = location {
                    self.coordinates = location.coordinate
                } else {
                    self.stopGeocoding()
                    self.showAlert(self.findButton, message: UdacityClient.ErrorMessages.locError)
                }
                
                performUIUpdatesOnMain {
                    self.stopGeocoding()
                    self.performSegue(withIdentifier: "AddPin", sender: self)
                }
            }
        }
    }
    
    // MARK: UITextFieldDelegate functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: Activity indicator control functions.
    func startGeocoding() {
        activityIndicator.startAnimating()
    }
    
    func stopGeocoding() {
        activityIndicator.stopAnimating()
    }
    
}
