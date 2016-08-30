![Logo](Assets/Logo.png)

*Do everything you were never meant to.*

*To The Apple's Core* serves as a house for testing the boundaries of what can be done on native iOS without a jailbreak.

```
"Hacking just means building something quickly or testing the boundaries of what can be done."

- Mark Zuckerberg 
```
All projects and snippits are made for, and run on entirely **non-jailbroken** devices. While untested, most following snippits should be able to run in Playground on iPad.

\* This project is for educational purposes and the code should not be used in any application targeted for the App Store. 

##:iphone: Setting the Lock Screen and Home Screen Images
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

##Retreive Installed App Info and Launch Apps from SpringBoard
<img src="Assets/AppExplorer-Logo.png" height="45">

I've created an entire project around this idea called [AppExplorer](https://github.com/joncardasis/AppExplorer). Check out the repo for more info and how you can implement it in your own project.




