//
//  NetworkManager.swift
//
//  Created by Cardasis, Jonathan (J.) on 9/1/16.
//  Copyright © 2016 Jonathan Cardasis. All rights reserved.
//

import Foundation

class NetworkManager {
    private struct BroadcomWifiInterfaces{
        static let standardWifi         = "en0"      //Standard Wifi Interface
        static let tethering            = "ap1"      //Access point interface used for Wifi tethering
        static let tetheringConnected   = "bridge"   //Interface for communicating to connected device via tether (Seems like the interface is always bridge100)
        static let awdl                 = "awdl0"    //Apple Wireless Direct Link interface - used for AirDrop, GameKit, AirPlay, etc.
        
        //pdp_ip (1-4) could be a PDS (Phone Data Service) data packet, the data portion of GSM. Since there are four I could assume one for each iphone antenna?
        //ipsec is for Internet Protocol Security
        //lo0 - software loopback network interface
    }
    
    /* Returns true if the device has Wifi turned on */
    static func wifiEnabled() -> Bool {
        if activeNetworkInterfaces().filter({ $0 == BroadcomWifiInterfaces.awdl }).count > 1 {
            //If more than 1 awdl10 interface, then wifi is turned on
            return true
        }
        return false
    }
    
    /* Returns true if the device is connected to a Wifi network */
    static func wifiConnected() -> Bool {
        if activeNetworkInterfaces().filter({ $0 == BroadcomWifiInterfaces.standardWifi }).count > 1 {
            //If more than 1 en0 interface then its connected
            return true
        }
        return false
    }
    
    //    MARK: Harder to implement since the interface turns off sometimes if you exit settings and theres not yet a connection
    //    static func tetheringEnabled() -> Bool {
    //        if activeNetworkInterfaces().filter({ $0 == BroadcomWifiInterfaces.tethering }).count > 1 {
    //            //If more than 1 ap1 interface, then tethering is truned on
    //            return true
    //        }
    //        return false
    //    }
    
    /* Returns true if the device is tethering its connection to another device */
    static func isTethering() -> Bool {
        if activeNetworkInterfaces().filter({ String($0).containsString(BroadcomWifiInterfaces.tetheringConnected) }).count > 0 {
            //If theres a bridge100 interface, then theres at least one connected device
            return true
        }
        return false
    }
    
    private static func activeNetworkInterfaces() -> [String]{
        var infs = ifaddrs() //network interfaces
        var infsPtr = withUnsafeMutablePointer(&infs){ UnsafeMutablePointer<ifaddrs>($0) }
        
        var array = [String]()
        
        if getifaddrs(&infsPtr) != -1 {
            var currentPtr = infsPtr
            
            while currentPtr != nil {
                let interface = currentPtr.memory as ifaddrs
                
                if (Int32(interface.ifa_flags) & IFF_UP) == IFF_UP {
                    if let interfaceName = String.fromCString(interface.ifa_name) {
                        array.append(interfaceName)
                    }
                }
                currentPtr = interface.ifa_next //step
            }
        }
        infsPtr.destroy()
        infsPtr.dealloc(1)
        
        return array
    }
}