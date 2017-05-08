//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 3/21/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient: NSObject {
    
    
    let session = URLSession.shared
    var sessionID: String? = nil
    static var accountKey: String? = ""
    static var firstName: String? = ""
    static var lastName: String? = ""

    
    //Singleton
    static let sharedInstance = UdacityClient()
    
    //MARK: Function to pass email and password to Udacity API to log user in.
    func loginToUdacity(_ username: String, password: String, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
      
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in

            guard (error == nil) else {
                completionHandler(false, error?.localizedDescription)
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "Your request returned a status code other than 2xx!")
                return
            }

            guard let data = data else {
                completionHandler(false, ErrorMessages.dataError)
                return
            }

            let range = Range(5 ..< data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandler(false,"Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard let session = parsedResult!["session"] as? [String : AnyObject], let sessionId = session["id"] as? String else {
                print("Can't find [session][id] in response")
                return
            }
            
            guard let account = parsedResult!["account"] as? [String : AnyObject], let accountKey = account["key"] as? String else {
                print("Can't find [account][key] in response")
                return
            }
            
            self.sessionID = sessionId
            UdacityClient.accountKey = accountKey
            self.getCurrentUserData(accountKey: accountKey) { (success, errorMessage) in
                if success {
                    ParseClient.sharedInstance.getStudentInformation( completionHandler: {(success, ErrorMessage) -> Void in
                        completionHandler(true, nil)
                    })
                } else {
                        completionHandler(false, ErrorMessages.userError)
                    }
            }

        }

        task.resume()
        
    }
    
    //MARK: Function to obtain student data of logged-in user.
    func getCurrentUserData(accountKey: String, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {

        let request = NSMutableURLRequest(url: NSURL(string: NSString(format: "https://www.udacity.com/api/users/%@", accountKey) as String)! as URL)
        let task = session.dataTask(with: request as URLRequest) { data, response, error in

            guard (error == nil) else {
                completionHandler(false, error?.localizedDescription)
                return
            }

            guard let data = data else {
                completionHandler(false, ErrorMessages.dataError)
                return
            }

            let range = Range(5 ..< data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandler(false,"Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard let userData = parsedResult!["user"] as? [String : AnyObject] else {
                print("Can't find [user] in response")
                return
            }
            guard let firstName = userData["first_name"] as? String, let lastName = userData["last_name"] as? String else {
                print("Can't find [user]['first_name'] or [user]['last_name'] in response")
                return
            }
            UdacityClient.firstName = firstName
            UdacityClient.lastName = lastName
            completionHandler(true, nil)
        }
        task.resume()
    }

    //MARK: Delete current user session.
    func deleteCurrentUser(_ completionHandler: @escaping (_ success: Bool, _ errorMsg: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let data = data else {
                completionHandler(false, ErrorMessages.dataError)
                return
            }
            
            let range = Range(5 ..< data.count)
            let newData = data.subdata(in: range)
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandler(false,"Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            if let _ = parsedResult["session"] as? [String:AnyObject] {
                self.sessionID = nil
                UdacityClient.firstName = ""
                UdacityClient.lastName = ""
                completionHandler(true, nil)
            } else {
                completionHandler(false, UdacityClient.ErrorMessages.genError)
            }
        }
        task.resume()
    }
}
