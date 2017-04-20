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
    var accountKey: String? = ""
    var firstName: String? = ""
    var lastName: String? = ""
    let login = LoginViewController()
    
    //Singleton
    static let sharedInstance = UdacityClient()
    
    func loginToUdacity(_ username: String, password: String, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
       
        /* 1/2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
      
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(false, ErrorMessages.dataError)
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
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
            self.accountKey = accountKey
            self.getCurrentUserData(accountKey: accountKey) { (success, errorMessage) in
                if success {
                    ParseClient.sharedInstance.getStudentInformation( completionHandler: {(success, ErrorMessage) -> Void in
                        completionHandler(true, nil)
                    })
                } else {
                        completionHandler(false, ErrorMessages.userError)
                    }
            }
            
            print("Session is \(sessionId) and account is \(accountKey)")
            
        }
        
        /* 7. Start the request */
        task.resume()
        
    }
    
    func getCurrentUserData(accountKey: String, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
        /* 1/2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: NSURL(string: NSString(format: "https://www.udacity.com/api/users/%@", accountKey) as String)! as URL)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(false, ErrorMessages.dataError)
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
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
            self.firstName = firstName
            self.lastName = lastName
            completionHandler(true, nil)
        }
        task.resume()
    }

}
