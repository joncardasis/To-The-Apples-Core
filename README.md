![Logo](Assets/Logo.png)
*Do everything you were never meant to.*

All projects and snippits are made for, and run on entirely **non-jailbroken** devices.

##Setting the Lock Screen and Home Screen Images
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

setWallpaper(image, location: .homescreen)
```
