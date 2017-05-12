//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/27/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddPinViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var newPinMap: MKMapView!
    @IBOutlet weak var addUrlText: UITextField!
    @IBOutlet weak var submitButton: RoundedButton!
    
    var inputCoordinates: CLLocationCoordinate2D?
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    var geocodedLocation: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubview(toBack: newPinMap)
        view.bringSubview(toFront: addUrlText)
        view.bringSubview(toFront: submitButton)
        addUrlText.delegate = self
        performUIUpdatesOnMain {
            self.addLocationPin(self.inputCoordinates!)

        }
    }

    //MARK: Submit information to Parse and return to sending VC (map or tableview)
    @IBAction func submitButtonPressed(_ sender: Any) {

        
        guard addUrlText?.text!.isEmpty == false else {
            showAlert(submitButton!, message: UdacityClient.ErrorMessages.urlInputError)
            return
        }
        ParseClient.sharedInstance.addNewStudent(mapString: geocodedLocation!, mediaURL: addUrlText.text!, latitude: lat!, longitude: long!,  completionHandler: {(success, ErrorMessage) -> Void in
            if success {
                performUIUpdatesOnMain {
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }

            } else {
                performUIUpdatesOnMain {
                    self.showAlert(AnyObject.self as AnyObject, message: UdacityClient.ErrorMessages.newPinError)
                }
            }
            })
   
    }

    //MARK: Cancel button tapped
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewResizerOnKeyboardShown()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
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
    
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //MARK: Add pin to the map
    func addLocationPin(_ coordinates: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        lat = coordinates.latitude
        long = coordinates.longitude
        annotation.title = "Your location"
        newPinMap.addAnnotation(annotation)
        
        // set region in order to center map
        
        let regionRadius: CLLocationDistance = 10000         // in meters
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates, regionRadius, regionRadius)
        
        newPinMap.setRegion(coordinateRegion, animated: true)
    }
    
   
    // MARK: -  Error alert setup
    func showAlert(_ sender: AnyObject, message: String) {
        let errMessage = message
        
        let alert = UIAlertController(title: nil, message: errMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: Function to allow the keyboard to disappear when the screen is tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    // MARK: Show/Hide Keyboard functions
    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShowForResizing),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHideForResizing),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func keyboardWillShowForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
        }
    }
    
    func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        }
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

}
