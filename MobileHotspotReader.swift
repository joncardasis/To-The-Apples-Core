//
//  MobileHotspotReader.swift
//
//  Created by Cardasis, Jonathan (J.) on 9/1/16.
//  Copyright © 2019 Jonathan Cardasis. All rights reserved.
//
//****REQUIRED SETUP****
//
// In order to use the SCDynamicStoreCreate and SCDynamicStoreCopyValue functions
// the __OSX_AVAILABLE_STARTING macro will need to be changed for these functions.
//
// The easiest way to do this is COMMAND + CLICK on the function names which will
// take you to the respective headers. Comment out the macro as seen here:
//
// SCDynamicStoreRef __nullable SCDynamicStoreCreate			(
//                 CFAllocatorRef			__nullable	allocator,
//                 CFStringRef					name,
//                 SCDynamicStoreCallBack		__nullable	callout,
//                 SCDynamicStoreContext		* __nullable	context
//                 )		/*__OSX_AVAILABLE_STARTING(__MAC_10_1,__IPHONE_NA)*/;
//
// AND
//
// CFPropertyListRef __nullable SCDynamicStoreCopyValue(
//                 SCDynamicStoreRef __nullable store,
//                 CFStringRef key
//                 )        /*__OSX_AVAILABLE_STARTING(__MAC_10_1,__IPHONE_NA)*/;
//

import Foundation
import SystemConfiguration

class MobileHotspotReader: NSObject{
    enum HotspotState: Int{
        /* These numbers are jurisdicted by iOS and checks for
         the value 1023 to know whether hotspot is on. */
        case off = 1022
        case on = 1023
    }
    
    static let sharedReader = MobileHotspotReader()
    
    var state: HotspotState? {
        guard let currentState = modemInfo?.value(forKey: "State") as? Int else { return nil }
        return currentState == HotspotState.on.rawValue ? .on : .off
    }
    
    var numberOfConnectedDevices: Int? {
        return modemValue(forKey: "Current") as? Int
    }
    
    var maxConnectedDevices: Int? {
        return modemValue(forKey: "Max") as? Int
    }
    
    var allowsConnections: Bool? {
        return modemValue(forKey: "MoreAllowed") as? Bool
    }
    
    var internalInterfaces: CFPropertyList? {
        return modemValue(forKey: "InternalInterfaces") as CFPropertyList
    }
    
    var externalInterfaces: CFPropertyList? {
        return modemValue(forKey: "ExternalInterfaces") as CFPropertyList
    }
    
    // MARK: Connection types
    
    var connectionsOverWifi: Int? {
        return (modemValue(forKey: "Type") as? NSObject)?.value(forKey: "AirPort") as? Int
    }
    
    var connectionsOverBluetooth: Int? {
        return (modemValue(forKey: "Type") as? NSObject)?.value(forKey: "Bluetooth") as? Int
    }
    
    var connectionsOverEthernet: Int? {
        return (modemValue(forKey: "Type") as? NSObject)?.value(forKey: "Ethernet") as? Int
    }
    
    var connectionsOverUSBEthernet: Int?  {
        return (modemValue(forKey: "Type") as? NSObject)?.value(forKey: "USB-Ethernet") as? Int
    }
    
    // MARK: - Private
    
    private override init() {}
    
    private let modemStore = SCDynamicStoreCreate(nil, "com.apple.MobileInternetSharing" as CFString, nil, nil)
    
    private var modemInfo: CFPropertyList? {
        return SCDynamicStoreCopyValue(modemStore, "com.apple.MobileInternetSharing" as CFString)
    }
    
    private func modemValue(forKey key: String) -> Any? {
        guard let latestInfo = modemInfo, let hosts = latestInfo.value(forKey: "Hosts") else {
            return nil
        }
        return (hosts as? NSObject)?.value(forKey: key)
    }
}