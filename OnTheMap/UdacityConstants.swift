//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 3/21/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation


extension UdacityClient {
    
//    struct UserInfo {
//        let accountKey: String
//        let firstName: String
//        let lastName: String
//        let linkUrl: String
//        let latitude: Double
//        let longitude: Double
//        let updatedAt: String
//        
//        init?(userDict: [String: AnyObject]) {
//            guard
//                let AccountKey = userDict["uniqueKey"] as? String,
//                let FirstName = userDict["firstName"] as? String,
//                let LastName = userDict["lastName"] as? String,
//                let LinkUrl = userDict["mediaURL"] as? String,
//                let Latitude = userDict["latitude"] as? Double,
//                let Longitude = userDict["longitude"] as? Double,
//                let UpdatedAt = userDict["updatedAt"] as? String
//                else {return nil}
//            
//            self.accountKey = AccountKey
//            self.firstName = FirstName
//            self.lastName = LastName
//            self.linkUrl = LinkUrl
//            self.latitude = Latitude
//            self.longitude = Longitude
//            self.updatedAt = UpdatedAt
//            
//        }
//        
//    }
    
    struct ErrorMessages {
        static let noInputError = "Please provide login details!"
        static let loginError = "Udacity Login failed. Incorrect username or password."
        static let dataError = "No data was returned."
        static let userError = "Unable to get user data."
        static let studentError = "Unable to get student data."
        static let genError = "An error was returned."
        static let inputError = "Please insert a location!"
        static let locError = "No matching location found."
    }
    
}

