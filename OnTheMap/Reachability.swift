//
//  Reachability.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 5/9/17.
//  Copyright © 2017 None. All rights reserved.
//

import Foundation
import SystemConfiguration


public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        //let isReachable = flags.contains(.reachable)
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        //let needsConnection = flags.contains(.connectionRequired)
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    class func isInternetAvailable(webSiteToPing: String?, completionHandler: @escaping (Bool) -> Void) {
        
        // 1. Check the WiFi Connection
        guard isConnectedToNetwork() else {
            completionHandler(false)
            return
        }
        
        // 2. Check the Internet Connection
        var webAddress = "https://www.google.com" // Default Web Site
        if let _ = webSiteToPing {
            webAddress = webSiteToPing!
        }
        
        guard let url = URL(string: webAddress) else {
            completionHandler(false)
            print("could not create url from: \(webAddress)")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil || response == nil {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        })
        
        task.resume()
    }
}
