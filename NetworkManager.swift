//
//  NetworkManager.swift
//
//  Created by Cardasis, Jonathan (J.) on 9/1/16.
//  Copyright © 2019 Jonathan Cardasis. All rights reserved.
//

import Foundation

class NetworkManager {
    private struct BroadcomWifiInterfaces {
        static let standardWifi         = "en0"      //Standard Wifi Interface
        static let tethering            = "ap1"      //Access point interface used for Wifi tethering
        static let tetheringConnected   = "bridge"   //Interface for communicating to connected device via tether (Seems like the interface is always bridge100)
        static let awdl                 = "awdl0"    //Apple Wireless Direct Link interface - used for AirDrop, GameKit, AirPlay, etc.
        
        //pdp_ip (1-4) could be a PDS (Phone Data Service) data packet, the data portion of GSM. Since there are four I could assume one for each iphone antenna?
        //ipsec is for Internet Protocol Security
        //lo0 - software loopback network interface
    }
    
    static let sharedManager = NetworkManager()
    
    /// Returns true if the device has Wifi turned on.
    func wifiEnabled() -> Bool {
        if activeNetworkInterfaceNames.filter({ $0 == BroadcomWifiInterfaces.awdl }).count > 1 {
            //If more than 1 awdl10 interface, then wifi is turned on
            return true
        }
        return false
    }
    
    /// Returns true if the device is connected to a Wifi network.
    func wifiConnected() -> Bool {
        if activeNetworkInterfaceNames.filter({ $0 == BroadcomWifiInterfaces.standardWifi }).count > 1 {
            //If more than 1 en0 interface then its connected
            return true
        }
        return false
    }
    
    //    MARK: Harder to implement since the interface turns off sometimes if you exit Settings and theres not yet a connection
    //    func tetheringEnabled() -> Bool {
    //        if activeNetworkInterfaceNames.filter({ $0 == BroadcomWifiInterfaces.tethering }).count > 1 {
    //            // If more than 1 ap1 interface, then tethering is truned on
    //            return true
    //        }
    //        return false
    //    }
    
    /// Returns true if the device is tethering its connection to another device.
    func isTethering() -> Bool {
        if activeNetworkInterfaceNames.filter({ $0.contains(BroadcomWifiInterfaces.tetheringConnected) }).count > 0 {
            //If theres a bridge100 interface, then theres at least one connected device
            return true
        }
        return false
    }
    
    // MARK: - Private
    private init() {}
    
    private var activeNetworkInterfaceNames: [String] {
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return [] }
        var interfaceNames = [String]()
        
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            if (flags & IFF_UP) == IFF_UP {
                let name = String(cString: ptr.pointee.ifa_name)
                interfaceNames.append(name)
            }
        }
        
        freeifaddrs(ifaddr)
        return interfaceNames
    }
}
