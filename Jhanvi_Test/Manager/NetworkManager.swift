//
//  NetworkManager.swift
//  Jhanvi_Test
//
//  Created by Jhanvi on 24/03/19.
//  Copyright © 2019 Jhanvi. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    //shared instance
    static let shared = NetworkManager()
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    
    func startNetworkReachabilityObserver() {
        var data:[String: Bool] = ["isConnected": false]
        // Post a notification with data
        reachabilityManager?.listener = { status in
            switch status {
                
            case .notReachable:
                print("The network is not reachable")
                data = ["isConnected": false]

            case .unknown :
                print("It is unknown whether the network is reachable")
                data = ["isConnected": false]


            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
                data = ["isConnected": true]


            case .reachable(.wwan):
                print("The network is reachable over the WWAN connection")
                data = ["isConnected": true]

            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Reachable"), object: nil, userInfo: data)

        }
        
        // start listening
        reachabilityManager?.startListening()
    }
}
