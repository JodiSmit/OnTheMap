//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 3/21/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation


extension UdacityClient {

    struct ErrorMessages {
        static let noInputError = "Please provide login details!"
        static let loginError = "Udacity Login failed. Incorrect username or password."
        static let dataError = "No data was returned."
        static let networkError = "No connection to the Internet!"
        static let userError = "Unable to get user data."
        static let studentError = "Unable to get student data."
        static let genError = "An error was returned."
        static let inputError = "Please insert a location!"
        static let locError = "No matching location found."
        static let newPinError = "Could not add pin."
        static let urlError = "URL cannot be accessed. Please try again or select another student."
        static let refreshError = "Could not refresh locations."
        static let logoutError = "Could not log user out!"
        static let urlInputError = "Please insert a valid URL."
        static let geoError = "Unable to process location. Please enter a valid location."
    }
    
}

