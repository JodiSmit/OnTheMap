//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 4/11/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation


struct StudentInfo {
   // let accountKey: String
    let firstName: String
    let lastName: String
    let linkUrl: String
    let latitude: Double
    let longitude: Double
    //let updatedAt: String
    
    init?(studentDict: [String: AnyObject]) {
       guard
 //       let AccountKey = studentDict["userId"] as? String,
        let FirstName = studentDict["firstName"] as? String,
        let LastName = studentDict["lastName"] as? String,
        let LinkUrl = studentDict["mediaURL"] as? String,
        let Latitude = studentDict["latitude"] as? Double,
        let Longitude = studentDict["longitude"] as? Double
        //let UpdatedAt = studentDict["updatedAt"] as? String
        else {return nil}
        
        //self.accountKey = AccountKey
        self.firstName = FirstName
        self.lastName = LastName
        self.linkUrl = LinkUrl
        self.latitude = Latitude
        self.longitude = Longitude
        //self.updatedAt = UpdatedAt

    }
    
}
