![Logo](Assets/Logo.png)

*Do everything you were never meant to.*

*To The Apple's Core* serves as a house for testing the boundaries of what can be done on native iOS without a jailbreak.

```
"Hacking just means building something quickly or testing the boundaries of what can be done."

- Mark Zuckerberg 
```
All projects and snippits are made for, and run on entirely **non-jailbroken** devices. While untested, most following snippits should be able to run in Playground on iPad.

\* This project is for educational purposes and the code should not be used in any application targeted for the App Store.

##Contents
- [:iphone: Setting Lock Screen and Home Screen Images](#iphone-setting-lock-screen-and-home-screen-images)
- [:battery: Retrieve Device Battery Info](#battery-retrieve-device-battery-info)
- [Retreive App Info from SpringBoard](#retrieve-app-info-from-springboard)
- [:airplane: Check for Airplane Mode](#airplane-check-for-airplane-mode)
- [:link:Gather Hotspot Info](#link-gather-hotspot-info)
- [:signal_strength: Obtain Networking Info (Wifi, Tethering, Etc.)](#signal_strength-obtain-networking-info)
 
---

##:iphone: Setting Lock Screen and Home Screen Images
#####WallpaperSetter.playground

```Swift
import Darwin
import UIKit

struct WallpaperLocation: OptionSetType {
    let rawValue: Int
    static let lockscreen = WallpaperLocation(rawValue: 1 << 0)
    static let homescreen = WallpaperLocation(rawValue: 1 << 1)
}


func setWallpaper(image: UIImage, location: WallpaperLocation) -> Bool{
    guard case let handle = dlopen("/System/Library/PrivateFrameworks/SpringBoardUI.framework/SpringBoardUI", RTLD_LAZY) where handle != nil else{
        return false
    }
    guard case let symbol = dlsym(handle, "SBSUIWallpaperSetImageAsWallpaperForLocations") where symbol != nil else{
        return false
    }
    
    typealias methodSignature = @convention(c) (AnyObject, NSInteger) -> ()
    let _ = unsafeBitCast(symbol, methodSignature.self)(image, location.rawValue)
    dlclose(handle)
    return true
}

setWallpaper(image, location: [.homescreen, .lockscreen])
```
##:battery: Retrieve Device Battery Info
```Swift
import Darwin
import Foundation

func deviceBatteryInfo() -> [Dictionary<String,AnyObject>]{
        guard case let handle = dlopen("/System/Library/PrivateFrameworks/BatteryCenter.framework/BatteryCenter", RTLD_LAZY) where handle != nil else {
            return []
        }
        guard let c = NSClassFromString("BCBatteryDeviceController") as? NSObjectProtocol else {
            return []
        }
        func sharedInstance() -> String{ return "sharedInstance" } //silence compiler warnings
        guard c.respondsToSelector(Selector(sharedInstance()))==true else {
            return []
        }
        
        let instance = c.performSelector(Selector(sharedInstance())).takeUnretainedValue()
        
        var batteryDictionaries: [[String:AnyObject]] = []
        if let devices = instance.valueForKey("connectedDevices") as? [AnyObject] {
            for battery in devices { //iOS supports multiple batteries
                /* Parse info into a dictionary */
                var dictionary: [String:AnyObject] = [:]
                
                var propertyCount: UInt32 = 0
                let properties = class_copyPropertyList(battery.classForCoder, &propertyCount)
                
                for i in 0..<propertyCount {
                    let cPropertyName = property_getName(properties[Int(i)])
                    
                    if let pName = String.fromCString(cPropertyName){ //Convert from C to Swift
                        dictionary[pName] = battery.valueForKey(pName) ?? nil
                    }
                }
                free(properties) //release objC property structs
                
                batteryDictionaries.append(dictionary)
            }
        }
    return batteryDictionaries
}


let allInfo = deviceBatteryInfo()
for batteryInfo in allInfo{
    print(batteryInfo)
}
```

##Retreive App Info from SpringBoard
<img src="Assets/AppExplorer-Logo.png" height="45">

I've created an entire project around this idea called [AppExplorer](https://github.com/joncardasis/AppExplorer). Check out the repo for more info and how you can implement it in your own project.


##:airplane: Check for Airplane Mode
#####AirplaneManager.swift
```Swift
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

print("Airplane Mode Enabled: \(AirplaneManager.airplaneModeEnabled())")
```


##:link:Gather Hotspot Info
#####MobileHotspotReader.swift
###Setup
In order to use the SCDynamicStoreCreate and SCDynamicStoreCopyValue functions
the `__OSX_AVAILABLE_STARTING` macro will need to be changed for these functions.

The easiest way to do this is COMMAND + CLICK on the function names in XCode which will
take you to the respective headers. Comment out the macros as seen here:

```Objective-C
SCDynamicStoreRef __nullable SCDynamicStoreCreate (
			CFAllocatorRef __nullable allocator,
			CFStringRef name,
			SCDynamicStoreCallBack __nullable callout,
			SCDynamicStoreContext * __nullable context
			)	/*	__OSX_AVAILABLE_STARTING(__MAC_10_1,__IPHONE_NA)*/;
```

```Objective-C
CFPropertyListRef __nullable SCDynamicStoreCopyValue(
			SCDynamicStoreRef __nullable store,
			CFStringRef key
			)	/*	__OSX_AVAILABLE_STARTING(__MAC_10_1,__IPHONE_NA)*/;

```

###Example Usage
```Swift
let reader = MobileHotspotReader.sharedReader
print("Connected Devices: \(reader.connectedDevices)")
print("Connected over Bluetooth: \(reader.connectionsOverBluetooth)")
        
reader.synchronize() //Gets updated values
print("Connected Devices: \(reader.connectedDevices)") //Check again
```

##:signal_strength: Obtain Networking Info (Wifi, Tethering, Etc.)
#####NetworkManager.swift
This code requires **no** private apis. I use low level C to obtain the info from the system.

###Example Usage:
```Swift
print("Wifi is Enabled     : \(NetworkManager.wifiEnabled())")
print("Wifi is Connected   : \(NetworkManager.wifiConnected())")
print("Currently Tethering : \(NetworkManager.isTethering())")
```

