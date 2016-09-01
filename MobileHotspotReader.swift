//
//  MobileHotspotReader.swift
//
//  Created by Cardasis, Jonathan (J.) on 9/1/16.
//  Copyright © 2016 Jonathan Cardasis. All rights reserved.
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
// {AND:}
//
// SCDynamicStoreRef __nullable SCDynamicStoreCreate			(
//                 CFAllocatorRef			__nullable	allocator,
//                 CFStringRef					name,
//                 SCDynamicStoreCallBack		__nullable	callout,
//                 SCDynamicStoreContext		* __nullable	context
//                 )  			/*__OSX_AVAILABLE_STARTING(__MAC_10_1,__IPHONE_NA)*/;
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
    var state: HotspotState?
    var connectedDevices: Int?
    var maxConnectedDevices: Int?
    var allowsConnections: Bool?
    
    //Number of connections over each type
    var connectionsOverWifi: Int?
    var connectionsOverBluetooth: Int?
    var connectionsOverEthernet: Int?
    var connectionsOverUSBEthernet: Int?
    
    var internalInterfaces: CFPropertyList?
    var externalInterfaces: CFPropertyList?
    
    
    override init(){
        super.init()
        synchronize()
    }
    
    /* Updates object properties */
    func synchronize(){
        let modemStore = SCDynamicStoreCreate(nil, "com.apple.MobileInternetSharing" as CFString, nil, nil)
        guard let info = SCDynamicStoreCopyValue(modemStore, "com.apple.MobileInternetSharing" as CFString) else{
            return
        }
        
        //Update State
        if let currentState = info.valueForKey("State") as? Int  {
            if currentState == HotspotState.on.rawValue{
                state = .on
            }
            else{
                state = .off
            }
        }
        
        //Update Connected Devices
        if let hosts = info.valueForKey("Hosts") {
            if let connected = hosts.valueForKey("Current") as? Int{
                connectedDevices = connected
            }
            if let maxConnected = hosts.valueForKey("Max") as? Int{
                maxConnectedDevices = maxConnected
            }
            if let moreAllowed = hosts.valueForKey("MoreAllowed") as? Bool{
                allowsConnections = moreAllowed
            }
            
            
            if let numAirport = hosts.valueForKey("Type")?.valueForKey("AirPort") as? Int{
                connectionsOverWifi = numAirport
            }
            if let numBluetooth = hosts.valueForKey("Type")?.valueForKey("Bluetooth") as? Int{
                connectionsOverBluetooth = numBluetooth
            }
            if let numEthernet = hosts.valueForKey("Type")?.valueForKey("Ethernet") as? Int{
                connectionsOverEthernet = numEthernet
            }
            if let numUSBEthernet = hosts.valueForKey("Type")?.valueForKey("USB-Ethernet") as? Int{
                connectionsOverUSBEthernet = numUSBEthernet
            }
        }
        
        
        //Update interfaces
        if let intInterfaces = info.valueForKey("InternalInterfaces"){
            internalInterfaces = intInterfaces
        }
        if let extInterfaces = info.valueForKey("ExternalInterfaces"){
            externalInterfaces = extInterfaces
        }
    }
}