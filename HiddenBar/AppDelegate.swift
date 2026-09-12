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

        if #available(macOS 27.0, *) {
            // macOS 27 can hide a managed status item without exposing a
            // reliable visibility signal to the app. Keep a Dock entry and
            // open Preferences so the user always has a recovery path.
            NSApp.setActivationPolicy(.regular)
            DispatchQueue.main.async {
                Util.showPrefWindow()
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            Util.showPrefWindow()
        }
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NSLog("App shutting down.")
    }
   
}

 
