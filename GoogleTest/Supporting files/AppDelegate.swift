//
//  AppDelegate.swift
//  GoogleTest
//
//  Created by Mehmed Tukulic on 25/03/2021.
//

import UIKit
import GoogleCast

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GCKSessionManagerListener{
    
    let kReceiverAppID = "C0868879"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GCKCastContext.sharedInstance().sessionManager.add(self)
        
        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: kReceiverAppID))
            options.physicalVolumeButtonsWillControlDeviceVolume = true
            GCKCastContext.setSharedInstanceWith(options)

        return true
    }


}
