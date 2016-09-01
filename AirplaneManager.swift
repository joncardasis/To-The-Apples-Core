//
//  AirplaneManager.swift
//
//  Created by Cardasis, Jonathan (J.) on 9/1/16.
//  Copyright © 2016 Jonathan Cardasis. All rights reserved.
//

import Foundation

class AirplaneManager{
    //Returns nil if the api could not be found
    static func airplaneModeEnabled() -> Bool?{
        guard case let handle = dlopen("/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport", RTLD_LAZY) where handle != nil else{
            return nil
        }
        guard let c = NSClassFromString("RadiosPreferences") as? NSObject.Type else {
            return nil
        }
        let radioPreferences = c.init()
        
        if radioPreferences.respondsToSelector(NSSelectorFromString("airplaneMode")) {
            return radioPreferences.valueForKey("airplaneMode")!.boolValue
        }
        
        return false
    }
}
