//
//  AppDelegate.swift
//  Messenger478
//
//  Created by Harrison Balogh on 10/10/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        print(Bundle.main.bundleURL.appendingPathComponent("private_rsa_id.der"))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application hkftd
    }


}

