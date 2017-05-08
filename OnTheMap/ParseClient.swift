//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/12/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation
import MapKit

class ParseClient: NSObject {
    
    let session = URLSession.shared
    
    //Singleton
    static let sharedInstance = ParseClient()
    
    static var students = [StudentInfo]()
    
    //MARK: Function to get max 100 student locations.
    func getStudentInformation(completionHandler:  @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {

        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
                
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            

            guard (error == nil) else {
                completionHandler(false, UdacityClient.ErrorMessages.genError)
                return
            }

            guard let data = data else {
                completionHandler(false, UdacityClient.ErrorMessages.dataError)
                return
            }

            var parsedResult: [String: AnyObject]? = nil
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            guard let results = parsedResult?["results"] as? [[String : AnyObject]] else {
                print("Can't find [results] in response")
                return
            }
            
            for result in results {
                if let student = StudentInfo(studentDict: result) {
                    ParseClient.students.append(student)
                    ParseClient.students.sort(by: {
                        $1.updatedAt < $0.updatedAt
                    })
                }
            }
            completionHandler(true, nil)
        }
        task.resume()
    }

    //MARK: Function to add new student location.
    func addNewStudent(mapString: String, mediaURL: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandler:  @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {

        let key = UdacityClient.accountKey!
        let first = UdacityClient.firstName!
        let last = UdacityClient.lastName!
             
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(first)\", \"lastName\": \"\(last)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
       
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                completionHandler(false, UdacityClient.ErrorMessages.genError)
                return
            }
            completionHandler(true, nil)
        }
        task.resume()
    }
}
