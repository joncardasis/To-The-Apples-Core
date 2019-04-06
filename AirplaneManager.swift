//
//  AirplaneManager.swift
//
//  Created by Cardasis, Jonathan (J.) on 9/1/16.
//  Copyright © 2019 Jonathan Cardasis. All rights reserved.
//

import Foundation

class AirplaneManager{
    
    /**
     Whether or not airplane mode is enabled. Returns nil if an error occured getting info from API.
     */
    static func isAirplaneModeEnabled() -> Bool?{
        guard case let handle = dlopen("/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport", RTLD_LAZY), handle != nil,
            let c = NSClassFromString("RadiosPreferences") as? NSObject.Type else {
                return nil
        }
        let radioPreferences = c.init()
        
        if radioPreferences.responds(to: NSSelectorFromString("airplaneMode")) {
            return (radioPreferences.value(forKey: "airplaneMode") as AnyObject).boolValue
        }
        return false
    }
}