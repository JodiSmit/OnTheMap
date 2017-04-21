//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/5/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
       
        super.viewDidLoad()
      
        loadStudentLocations()
                
    }
    
    func loadStudentLocations() {
        
        var annotations = [MKPointAnnotation]()
        let locations = ParseClient.students
        
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
                let alertController = UIAlertController()
                
                alertController.title = "No Valid Url"
                alertController.message = "The provided URL can't be opened, select a different student"
                
                let dismissAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel)
                alertController.addAction(dismissAction)
                
                present(alertController, animated: true, completion: nil)
            }
        }
    }

    
}
