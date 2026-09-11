//
//  AppDelegate.swift
//  Hidden Bar
//
//  Maintained by Andrea Beghè in 2026.
//  Copyright © 2026 Andrea Beghè. Licensed under the MIT License.
//

import AppKit
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate{
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("App launched.")
        StatusBarController.setup()
        HotKeyManager.setupHotKey()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NSLog("App shutting down.")
    }
   
}

 
