//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/5/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadStudentLocations()
        
    }
    
    //MARK: Load pins on the map of student locations
    func loadStudentLocations() {
        
        var annotations = [MKPointAnnotation]()
        let locations = StudentDataSource.sharedInstance.studentData
        
        for studentLocation in locations {
            
            let lat = CLLocationDegrees(studentLocation.latitude)
            let long = CLLocationDegrees(studentLocation.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let first = (studentLocation.firstName)
            let last = (studentLocation.lastName)
            let mediaURL = (studentLocation.linkUrl)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotation.title = "\(String(describing: first)) \(String(describing: last))"
            annotation.subtitle = mediaURL
            annotations.append(annotation)
            
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(annotations)
            }
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
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let studUrl = URL(string: ((view.annotation?.subtitle)!)!), app.canOpenURL(studUrl) {
                app.open(studUrl, options: [:])
            } else {
                self.showAlert((Any).self, message: UdacityClient.ErrorMessages.urlError)
            }
        }
    }
    
    //Function to clear all pins
    func removeAllAnnotations() {
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
    }
    
    //MARK: Remove and re-add all pins (refresh)
    @IBAction func refreshStudentPins(_ sender: Any) {
        self.removeAllAnnotations()
        
        StudentDataSource.sharedInstance.studentData.removeAll()
        ParseClient.sharedInstance.getStudentInformation( completionHandler: {(success, ErrorMessage) -> Void in
            if success {
                self.loadStudentLocations()
            } else {
                self.showAlert((Any).self, message: UdacityClient.ErrorMessages.refreshError)
            }
        })
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
